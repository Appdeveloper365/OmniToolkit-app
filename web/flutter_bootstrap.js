// Flutter bootstrap for OmniToolkit.
//
// WARNING: the two bare template placeholders below are substituted at build
// time by `flutter build web`. The tool substitutes them wherever they appear,
// including inside a `//` comment, so each one MUST sit at the very start of its
// own line with no other text before it.
//
// The first placeholder is replaced with the Flutter loader (flutter.js)
// source; the second is replaced with the generated build configuration that
// tells the loader which entrypoint to run. If either one is missing, renamed
// or commented out, the build still succeeds but the loader is never injected,
// main.dart.js is never requested, and the app stays on a blank page.

{{flutter_js}}
{{flutter_build_config}}

(() => {
  'use strict';

  // Static hosts such as GitHub Pages cannot send the COOP/COEP headers
  // required for cross-origin isolation, so Skwasm can only run in
  // single-threaded mode there. Request that explicitly and silence the
  // informational multi-threading warning. This configuration is only
  // consulted by the Skwasm engine; CanvasKit builds ignore it.
  _flutter.loader.load({
    config: {
      suppressMultithreadingWarning: true,
      forceSingleThreadedSkwasm: true,
    },
  });
})();
