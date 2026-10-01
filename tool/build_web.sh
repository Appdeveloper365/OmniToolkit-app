#!/usr/bin/env bash
#
# Builds the OmniToolkit web PWA.
#
# OmniToolkit is fully offline-first: no backend, no account, no payment
# system, so no build-time configuration is required.
#
# --no-web-resources-cdn bundles CanvasKit locally so the app needs no
# third-party origin, is cacheable by the same-origin service worker, and does
# not depend on COOP/COEP headers (GitHub Pages cannot send them).

set -euo pipefail

cd "$(dirname "$0")/.."

exec flutter build web \
  --release \
  --no-web-resources-cdn \
  --base-href "${OMNI_BASE_HREF:-/OmniToolkit-app/}" \
  "$@"
