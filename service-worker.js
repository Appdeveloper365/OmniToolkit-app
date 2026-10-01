const CACHE_NAME = 'omnitoolkit-pwa-v7';

self.addEventListener('install', (event) => {
  event.waitUntil(self.skipWaiting());
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const cacheNames = await caches.keys();
    await Promise.all(
      cacheNames
        .filter((name) => name.startsWith('omnitoolkit-pwa-') && name !== CACHE_NAME)
        .map((name) => caches.delete(name)),
    );
    await self.clients.claim();
  })());
});

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

self.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return;
  const requestUrl = new URL(event.request.url);
  if (requestUrl.origin !== self.location.origin || requestUrl.pathname.includes('/downloads/')) return;

  const isNavigation = event.request.mode === 'navigate';
  event.respondWith((async () => {
    const cache = await caches.open(CACHE_NAME);
    try {
      const response = await fetch(event.request, { cache: 'no-store' });
      if (response.ok) {
        const securedResponse = addSecurityHeaders(response);
        await cache.put(event.request, securedResponse.clone());
      }
      return addSecurityHeaders(response);
    } catch (error) {
      const cached = await cache.match(event.request);
      if (cached) return cached;
      if (isNavigation) {
        const shell = await cache.match('./');
        if (shell) return shell;
      }
      // Never throw - return a network error response instead
      return new Response('', { status: 504, statusText: 'Gateway Timeout' });
    }
  })());
});