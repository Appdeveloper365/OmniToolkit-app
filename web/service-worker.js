// Service Worker for OmniToolkit with downloads bypass
const CACHE_NAME = 'omnitoolkit-v1';
const DOWNLOADS_PATH = '/OmniToolkit-app/downloads/';

self.addEventListener('install', (event) => {
  console.log('[Service Worker] Installing...');
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  console.log('[Service Worker] Activating...');
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  
  // IMPORTANT: Bypass service worker for downloads directory
  // Return network response for all /downloads/* requests
  if (url.pathname.includes(DOWNLOADS_PATH)) {
    console.log('[Service Worker] Bypassing cache for download:', url.pathname);
    event.respondWith(fetch(event.request));
    return;
  }
  
  // For other requests, use cache-first strategy
  event.respondWith(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.match(event.request).then((response) => {
        if (response) {
          return response;
        }
        
        return fetch(event.request).then((response) => {
          // Don't cache non-successful responses
          if (!response || response.status !== 200 || response.type === 'error') {
            return response;
          }
          
          // Clone and cache successful responses
          const responseToCache = response.clone();
          cache.put(event.request, responseToCache);
          return response;
        }).catch(() => {
          // Return offline page if available
          return new Response('Offline - No cached version available');
        });
      });
    })
  );
});
