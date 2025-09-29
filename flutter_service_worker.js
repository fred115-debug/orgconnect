'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "7910870d022b9f2caf66a891d42bf686",
"assets/AssetManifest.bin.json": "c3f6facad7bb4acd53fa2d66b3f0a389",
"assets/AssetManifest.json": "cfd5df8b997fcff1502c99de9c1d4071",
"assets/assets/26de0606-cce7-4d3a-89c6-daf44e5f19bc.jpg": "cac3d2ff9347132c13a6e5efb62b3c52",
"assets/assets/AssetManifest.bin": "7910870d022b9f2caf66a891d42bf686",
"assets/assets/AssetManifest.bin.json": "c3f6facad7bb4acd53fa2d66b3f0a389",
"assets/assets/AssetManifest.json": "cfd5df8b997fcff1502c99de9c1d4071",
"assets/assets/bccaces.jpg": "0c324f0dfd12355ae4614b0edb2e2e9b",
"assets/assets/bccdc.jpg": "4e2889a209cbe86520411bdedfb3e5d6",
"assets/assets/bccmusicality.jpg": "df24c089fb905f1bc5784bd72dbc5be4",
"assets/assets/bccnigthngale.jpg": "cb3f00b4a68edebe335c4e717007123b",
"assets/assets/christiancampusministry.jpg": "a61270d852e289f2c001a9b6128815b2",
"assets/assets/codehex.jpg": "644cf04a92472c439bcc99475d23e513",
"assets/assets/collegeelegante.jpg": "2c25b2e102290f4c16419e4f1388525c",
"assets/assets/craftycreatorsclub.jpg": "b32c7dbb4f9a7ecd1723f44b8912ac64",
"assets/assets/cronica.jpg": "ea74e43cbe933d9747f8d5a2f136c8fe",
"assets/assets/culturadefelipino.jpg": "debd2c5fe2acecf6d70e0b22ac16b18c",
"assets/assets/drumandlyre.jpg": "c7a68903642f76f43f019ce3416a67fb",
"assets/assets/eltiatro.jpg": "394ddafbcd08fbaa89f3bd475fd4c280",
"assets/assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/assets/genderunited.jpg": "0dabb9ada03543842a1f1c940f0def97",
"assets/assets/inkwell.jpg": "0ea04acdef4ca69c830d66d3edb5177d",
"assets/assets/kasangasquad.jpg": "9328bb0ecdd1a702397116f65ebd322d",
"assets/assets/motoclub.jpg": "60fff91319f7181d397c4045b2176a57",
"assets/assets/newheader.jpg": "546a69b47e9f0e1977864ee607a06d94",
"assets/assets/NOTICES": "da3b86d4d88889d09b687a0050028bf0",
"assets/assets/orgconnectLogo.jpg": "40a5ebbf8861ccc4751c3d7c3f63920f",
"assets/assets/pageturnersbookclub.jpg": "a5904aee80225d93f9c0e8eb02521ef3",
"assets/assets/peerfacilatatorscircles.jpg": "d461d81438c85c18b6a7495ecf4a4115",
"assets/assets/primerabida.jpg": "6654f0c799cb797a1dd57819fb321d15",
"assets/assets/scap.jpg": "3ac4da3d7d040192c1ddb950ea8b0ca3",
"assets/assets/screenheader.jpg": "f7630125ceaf39f879ba735e3db7f33e",
"assets/assets/speakicomics.jpg": "18dc847a6831b0d5c7940370ca6b5cb3",
"assets/assets/speakiconics.jpg": "18dc847a6831b0d5c7940370ca6b5cb3",
"assets/assets/ssg.jpg": "1e45f003e59d500999ffcce41746a46e",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "ef0fb199ece3200f330d1cb2672bf5e6",
"assets/NOTICES": "da3b86d4d88889d09b687a0050028bf0",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "33d53f76cf69acf98c36cff43f97c6f8",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "6b7ca544c5c666f9ed1e28f726c7cc24",
"/": "6b7ca544c5c666f9ed1e28f726c7cc24",
"main.dart.js": "162a57bc75fe696a2628a9d6426c52a3",
"manifest.json": "18b05de58f5aeed2ffa6be1246cc43f1",
"version.json": "53fb59e54fb87bb44dba7c2200e1dead"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
