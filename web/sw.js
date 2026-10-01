const CACHE_NAME = 'omnitoolkit-v6';
const ASSETS_TO_CACHE = [
  './',
  './index.html',
  './manifest.json',
  './favicon.png',
  './icons/Icon-192.png',
  './icons/Icon-512.png'
];

function addSecurityHeaders(response) {
  const headers = new Headers(response.headers);
  headers.set('X-Content-Type-Options', 'nosniff');
  headers.set('X-Frame-Options', 'DENY');
  headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
  headers.set('Permissions-Policy', 'accelerometer=(), camera=(), geolocation=(self), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=(), interest-cohort=()');
  // COOP only (no COEP) - COEP: require-corp breaks cross-origin resources like
  // gstatic.com, fonts.googleapis.com, api.met.no, radio-browser.info, Firebase
  headers.set('Cross-Origin-Opener-Policy', 'same-origin');
  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers: headers,
  });
}

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(ASSETS_TO_CACHE).catch(() => {});
    })
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cache) => {
          if (cache !== CACHE_NAME) {
            return caches.delete(cache);
          }
        })
      );
    })
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;
  const url = new URL(event.request.url);
  const scopePath = new URL(self.registration.scope).pathname;
  const downloadsPath = `${scopePath.endsWith('/') ? scopePath : `${scopePath}/`}downloads/`;
  const isDownloadRequest = url.pathname.startsWith(downloadsPath);
  const isNavigationRequest = event.request.mode === 'navigate';

  if (isDownloadRequest) {
    event.respondWith(fetch(event.request));
    return;
  }

  event.respondWith(
    caches.match(event.request).then((response) => {
      if (response) {
        return response;
      }

      const networkRequest = fetch(event.request);
      return networkRequest.then((response) => {
        if (response.ok) {
          return addSecurityHeaders(response);
        }
        return response;
      }).catch((error) => {
        if (isNavigationRequest) {
          return caches.match('./index.html');
        }
        // Never throw - return a network error response
        return new Response('', { status: 504, statusText: 'Gateway Timeout' });
      });
    })
  );
});