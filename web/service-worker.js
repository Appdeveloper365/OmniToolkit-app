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
  // Only body-bearing 2xx responses can be re-wrapped. Opaque responses
  // (status 0) and null-body statuses (101/204/205/304) throw a TypeError
  // when passed to the Response constructor.
  if (response.status === 0 || [101, 204, 205, 304].includes(response.status)) {
    return response;
  }
  const headers = new Headers(response.headers);
  headers.set('X-Content-Type-Options', 'nosniff');
  headers.set('X-Frame-Options', 'DENY');
  headers.set('Referrer-Policy', 'strict-origin-when-cross-origin');
  headers.set('Permissions-Policy', 'accelerometer=(), camera=(), geolocation=(self), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=(), interest-cohort=()');
  // COOP only (no COEP) - COEP: require-corp breaks cross-origin resources like
  // gstatic.com, fonts.googleapis.com, api.met.no, radio-browser.info
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

  // Don't intercept Flutter navigation requests - let Flutter handle routing
  const isFlutterNavigation = event.request.mode === 'navigate' || 
    (event.request.headers.get('Accept') || '').includes('text/html');
  if (isFlutterNavigation) return;

  event.respondWith((async () => {
    const cache = await caches.open(CACHE_NAME);
    try {
      const response = await fetch(event.request, { cache: 'no-store' });
      if (!response.ok) {
        // Return non-OK (redirects, 404s, opaque) responses untouched: they
        // cannot always be re-wrapped with new Response(...).
        return response;
      }
      const securedResponse = addSecurityHeaders(response);
      await cache.put(event.request, securedResponse.clone());
      return securedResponse;
    } catch (error) {
      const cached = await cache.match(event.request);
      if (cached) return cached;
      return new Response('', { status: 504, statusText: 'Gateway Timeout' });
    }
  })());
});
