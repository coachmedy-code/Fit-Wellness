// Minimální service worker - umožňuje "Přidat na plochu" a základní offline cache.
const CACHE_NAME = 'wellness-cache-v1';
const FILES_TO_CACHE = [
  'index.html',
  'manifest.json',
  'icon-192.png',
  'icon-512.png',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(FILES_TO_CACHE))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  // síť má přednost (potřebujeme čerstvá data ze Supabase), cache je jen záloha
  event.respondWith(
    fetch(event.request).catch(() => caches.match(event.request))
  );
});
