const CACHE='travia-shell-v7';
const ASSETS=['/','/index.html','/app.js','/sync-client.js','/core/model.mjs','/ocr-client.js','/styles.css','/manifest.webmanifest','/node_modules/pdfjs-dist/build/pdf.mjs','/node_modules/pdfjs-dist/build/pdf.worker.mjs'];
self.addEventListener('install',event=>event.waitUntil(caches.open(CACHE).then(cache=>cache.addAll(ASSETS)).then(()=>self.skipWaiting())));
self.addEventListener('activate',event=>event.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(key=>key!==CACHE).map(key=>caches.delete(key)))).then(()=>self.clients.claim())));
self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') return;
  const networkFirst = event.request.mode === 'navigate' || new URL(event.request.url).pathname.endsWith('/sw.js');
  if (networkFirst) {
    event.respondWith(fetch(event.request).then(response => {
      const copy = response.clone();
      caches.open(CACHE).then(cache => cache.put(event.request, copy));
      return response;
    }).catch(() => caches.match(event.request).then(cached => cached || caches.match('/'))));
    return;
  }
  event.respondWith(
    caches.match(event.request).then(cached => cached || fetch(event.request).then(response => {
      const copy = response.clone();
      caches.open(CACHE).then(cache => cache.put(event.request, copy));
      return response;
    }).catch(() => caches.match('/')))
  );
});
