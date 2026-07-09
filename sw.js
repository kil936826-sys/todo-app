// Service Worker — 网络优先（始终最新）+ 离线兜底
const CACHE = 'daily-v3';

self.addEventListener('install', e => {
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
  );
  self.clients.claim();
});

self.addEventListener('fetch', e => {
  // 图片 / 图标：缓存优先
  if (e.request.url.match(/\.(png|jpg|jpeg|gif|svg|ico)/)) {
    e.respondWith(
      caches.match(e.request).then(c => c || fetch(e.request).then(r => {
        if (r.ok) { let cl = r.clone(); caches.open(CACHE).then(c2 => c2.put(e.request, cl)); }
        return r;
      }))
    );
    return;
  }

  // HTML / JS / CSS / 其他：网络优先
  e.respondWith(
    fetch(e.request).then(r => {
      if (r.ok) { let cl = r.clone(); caches.open(CACHE).then(c => c.put(e.request, cl)); }
      return r;
    }).catch(() => caches.match(e.request))
  );
});

// 发现新版本时通知所有页面刷新
self.addEventListener('message', e => {
  if (e.data === 'skipWaiting') self.skipWaiting();
});
