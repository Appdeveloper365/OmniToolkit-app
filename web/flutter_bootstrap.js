// Flutter bootstrap - forces single-threaded mode on Windows (no COOP/COEP needed)

(() => {
  'use strict';

  const isWindows = navigator.userAgent.includes('Windows');

  if (isWindows) {
    console.log('[Flutter Bootstrap] Windows detected - forcing single-threaded Skwasm');

    // Override the loader's load method to inject forceSingleThreadedSkwasm config
    const originalLoaderInit = window._flutter?.loader;
    if (window._flutter) {
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

    // Also set on buildConfig if available
    window._flutter = window._flutter || {};
    window._flutter.buildConfig = window._flutter.buildConfig || {};
    window._flutter.buildConfig.forceSingleThreadedSkwasm = true;
    window._flutter.buildConfig.suppressMultithreadingWarning = true;
  }
})();