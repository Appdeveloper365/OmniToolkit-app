#!/usr/bin/env bash
#
# Builds the OmniToolkit web PWA.
#
# The Firebase client configuration is NOT in source: it is read from a
# git-ignored file (tool/firebase_defines.json). Create it once from the
# template:
#
#   cp tool/firebase_defines.example.json tool/firebase_defines.json
#   # then fill in the values from the Firebase console
#
# If the file is absent the build still succeeds - the app then runs with the
# local-first modules only and reports cloud billing/entitlement features as
# unavailable (lib/main.dart checks DefaultFirebaseOptions.isConfigured).

set -euo pipefail

cd "$(dirname "$0")/.."

DEFINES_FILE="tool/firebase_defines.json"
DEFINE_ARGS=()

if [ -f "$DEFINES_FILE" ]; then
  DEFINE_ARGS+=(--dart-define-from-file="$DEFINES_FILE")
  echo "Using Firebase build-time config from $DEFINES_FILE"
else
  echo "WARNING: $DEFINES_FILE not found - building without cloud features."
  echo "         See tool/firebase_defines.example.json."
fi

# --no-web-resources-cdn bundles CanvasKit locally so the app needs no
# third-party origin, is cacheable by the same-origin service worker, and does
# not depend on COOP/COEP headers (GitHub Pages cannot send them).
exec flutter build web \
  --release \
  --no-web-resources-cdn \
  --base-href "${OMNI_BASE_HREF:-/OmniToolkit-app/}" \
  "${DEFINE_ARGS[@]}" \
  "$@"
