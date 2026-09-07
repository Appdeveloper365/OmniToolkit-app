const CACHE_NAME = 'omnitoolkit-v2';
const ASSETS_TO_CACHE = [
  './',
  './index.html',
  './manifest.json',
  './favicon.png',
  './icons/Icon-192.png',
  './icons/Icon-512.png'
];

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
      return networkRequest.catch((error) => {
        if (isNavigationRequest) {
          return caches.match('./index.html');
        }
        throw error;
      });
    })
  );
});
