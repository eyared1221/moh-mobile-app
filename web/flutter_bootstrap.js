{{flutter_js}}
{{flutter_build_config}}

const pwaServiceWorkerUrl = 'app_service_worker.js';
const serviceWorkerReadyTimeoutMs = 2500;

function isSecureContextForPwa() {
  return (
    window.location.protocol === 'https:' ||
    window.location.hostname === 'localhost' ||
    window.location.hostname === '127.0.0.1'
  );
}

function withTimeout(promise, timeoutMs) {
  return new Promise((resolve, reject) => {
    const timeoutId = window.setTimeout(() => {
      reject(new Error(`Timed out after ${timeoutMs}ms`));
    }, timeoutMs);

    promise.then(
      (value) => {
        window.clearTimeout(timeoutId);
        resolve(value);
      },
      (error) => {
        window.clearTimeout(timeoutId);
        reject(error);
      },
    );
  });
}

async function registerPwaServiceWorker() {
  if (!('serviceWorker' in navigator) || !isSecureContextForPwa()) {
    return;
  }

  const existingRegistrations = await navigator.serviceWorker.getRegistrations();
  await Promise.all(
    existingRegistrations
      .filter((registration) =>
        registration.active?.scriptURL.includes('flutter_service_worker.js') ||
        registration.waiting?.scriptURL.includes('flutter_service_worker.js') ||
        registration.installing?.scriptURL.includes('flutter_service_worker.js'),
      )
      .map((registration) => registration.unregister()),
  );

  const serviceWorkerUrl = new URL(pwaServiceWorkerUrl, window.location.href);
  const registration = await navigator.serviceWorker.register(serviceWorkerUrl);
  await withTimeout(navigator.serviceWorker.ready, serviceWorkerReadyTimeoutMs);
  return registration;
}

window.addEventListener('load', async function () {
  try {
    await registerPwaServiceWorker();
  } catch (error) {
    console.warn('PWA service worker registration failed:', error);
  }

  _flutter.loader.load({
    onEntrypointLoaded: async function (engineInitializer) {
      const appRunner = await engineInitializer.initializeEngine();
      await appRunner.runApp();
    },
  });
});
