// Flutter bootstrap - configures Flutter loader before flutter.js runs

(() => {
  'use strict';

  const isWindows = navigator.userAgent.includes('Windows');

  // Always initialize _flutter.buildConfig so FlutterLoader.load() can read it.
  // Without this, flutter.js throws: "FlutterLoader.load requires _flutter.buildConfig to be set"
  window._flutter = window._flutter || {};
  window._flutter.buildConfig = window._flutter.buildConfig || {};

  if (isWindows) {
    console.log('[Flutter Bootstrap] Windows detected - forcing single-threaded Skwasm');

    window._flutter.buildConfig.forceSingleThreadedSkwasm = true;
    window._flutter.buildConfig.suppressMultithreadingWarning = true;

    // Override the loader's load method to inject single-threaded config
    const originalLoad = window._flutter.loader?.load;
    if (originalLoad) {
      window._flutter.loader.load = function(config = {}) {
        config.forceSingleThreadedSkwasm = true;
        config.suppressMultithreadingWarning = true;
        console.log('[Flutter Bootstrap] Injected single-threaded config:', config);
        return originalLoad.call(this, config);
      };
    }
  }

  // Also set loaderConfig for the inline config in index.html (harmless on all platforms)
  window._flutter.loaderConfig = {
    suppressMultithreadingWarning: true,
    forceSingleThreadedSkwasm: isWindows,
  };
  console.log('[Flutter Bootstrap] Config set:', window._flutter.loaderConfig);
})();
