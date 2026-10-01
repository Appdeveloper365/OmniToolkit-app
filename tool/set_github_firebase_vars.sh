#!/usr/bin/env bash
#
# Publishes the local Firebase build-time config to this repository as GitHub
# Actions variables, so the deploy workflow can bake it into the web bundle.
#
# The values are read from the git-ignored tool/firebase_defines.json, so no
# credential is ever typed by hand or stored in this script.
#
# Requires the GitHub CLI, authenticated with access to the repository:
#
#   brew install gh            # macOS
#   gh auth login              # once
#
# Then:
#
#   ./tool/set_github_firebase_vars.sh            # set as repository variables
#   ./tool/set_github_firebase_vars.sh --secret   # set as repository secrets
#
# Re-run it any time the Firebase values change. See OWNER_DEPLOYMENT_CHECKLIST.md
# for the remaining Cloud Functions / Stripe setup.

set -euo pipefail

cd "$(dirname "$0")/.."

REPO="Appdeveloper365/OmniToolkit-app"
DEFINES_FILE="tool/firebase_defines.json"
KIND="variable"
[ "${1:-}" = "--secret" ] && KIND="secret"

if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: the GitHub CLI (gh) is not installed." >&2
  echo "       macOS: brew install gh    then: gh auth login" >&2
  exit 1
fi

if [ ! -f "$DEFINES_FILE" ]; then
  echo "ERROR: $DEFINES_FILE not found." >&2
  echo "       Create it from tool/firebase_defines.example.json first." >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "ERROR: gh is not authenticated. Run: gh auth login" >&2
  exit 1
fi

echo "Publishing Firebase build-time config to $REPO as $KIND(s)..."

# Read each FIREBASE_* key from the git-ignored JSON file.
while IFS= read -r line; do
  key="${line%%=*}"
  value="${line#*=}"
  [ -z "$key" ] && continue
  gh "$KIND" set "$key" --body "$value" --repo "$REPO"
  echo "  set $KIND $key"
done < <(python3 - "$DEFINES_FILE" <<'PY'
import json
import sys

with open(sys.argv[1]) as fh:
    for key, value in json.load(fh).items():
        if key.startswith("FIREBASE_"):
            print(f"{key}={value}")
PY
)

echo
echo "Done. Re-run the 'Build & Deploy Web PWA' workflow to publish a build"
echo "with cloud billing and entitlement features enabled:"
echo "  gh workflow run deploy.yml --repo $REPO"
