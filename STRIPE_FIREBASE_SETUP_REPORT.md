# Stripe + Firebase Functions v2 Setup (OmniToolkit PWA)

Target: https://appdeveloper365.github.io/OmniToolkit-app/ (branch `pwa-production`).
BTIM_OmniToolkit.msix / Windows worktree — NOT touched.

## What Was Configured From Code

1. **`firebase.json`** (new) — points the `functions` source at `functions/`
   and `firestore.rules` at the repo's existing rules file, using the
   already-configured Firebase project.
2. **`.firebaserc`** (new) — sets the default project to `omnitoolkit-b7de8`,
   the Firebase project ID already used by this app's `firebase_options.dart`
   / Google services config. No new project was created.
3. **`functions/index.js`** — migrated to Firebase Functions **v2**
   (`firebase-functions/v2/https`, `defineSecret`) matching the requested
   pattern, while preserving this app's existing no-login-required purchase
   flow:
   - `createStripeCheckoutSession` (callable): auth optional, requires
     `disclaimerAccepted: true`, reuses/creates a Stripe Customer for
     signed-in users, lets Stripe Checkout collect email for anonymous
     purchasers, returns `{ sessionUrl, url }` (both keys populated for
     compatibility with the existing client call).
   - `stripeWebhook` (HTTPS): verifies the Stripe signature, fulfills
     `checkout.session.completed`, writes to `entitlements/{purchaseEmail}`
     (keyed by email so anonymous purchases can be matched later), and
     mirrors to `users/{uid}` + `users/{uid}/payments/{sessionId}` when a
     uid is available.
   - `checkEntitlementByEmail` (callable, public) and
     `checkEntitlementForSignedInUser` (callable, auth required) — unchanged
     from the prior turn, retained for status checks / entitlement
     reconciliation.
   - Secrets are read via `defineSecret("STRIPE_SECRET_KEY")`,
     `defineSecret("STRIPE_WEBHOOK_SECRET")`, `defineSecret("STRIPE_PRICE_ID")`
     — i.e. Firebase Secret Manager, not hardcoded values.
4. **`functions/package.json`** — bumped to `firebase-admin@^12`,
   `firebase-functions@^5` (v2 API), `stripe@^15`, `node: 20` engine, and
   `npm install` was run to refresh `functions/package-lock.json`.
5. **`functions/.gitignore`** (new) — excludes `functions/node_modules/` and
   `.env*` so secrets/dependencies are never committed.
6. **`firestore.rules`** — added a `users/{uid}/payments/{paymentId}` rule
   (owner-read only, Admin-SDK-only writes) alongside the existing
   `entitlements/{email}` and `users/{uid}` rules.

## What Could NOT Be Done From This Environment (requires your action)

This sandbox has no browser for interactive OAuth and no Firebase CI token,
Google service-account key, or Stripe credentials anywhere in the repo or
environment — so the following must be run by a human/CI with real
credentials:

```powershell
cd C:\Users\bala\omnitoolkit-pwa
npm install -g firebase-tools     # or use npx firebase-tools
firebase login                    # interactive browser login
firebase use omnitoolkit-b7de8    # confirm project (already set in .firebaserc)

firebase functions:secrets:set STRIPE_SECRET_KEY
firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
firebase functions:secrets:set STRIPE_PRICE_ID

firebase deploy --only functions
firebase deploy --only firestore:rules
```

After `firebase deploy --only functions`, take the printed `stripeWebhook`
URL and add it in the Stripe Dashboard → Webhooks → Add endpoint, listening
for `checkout.session.completed`. If the webhook secret differs from what
was set above, re-run `firebase functions:secrets:set STRIPE_WEBHOOK_SECRET`
and redeploy.

Also confirm the Firebase project `omnitoolkit-b7de8` is on the **Blaze**
plan (required for outbound network calls to Stripe from Cloud Functions).

## Validation Performed In This Session

- `node --check functions/index.js` — passes.
- `npm install` in `functions/` — succeeds (240 packages, no errors; only
  an EBADENGINE warning for local Node 24 vs. the functions runtime's
  Node 20 target, which does not affect Cloud Functions deployment since
  Cloud Build uses the pinned `engines.node` version, not this machine's).
- `flutter analyze` — No issues found.
- `flutter test --concurrency=1` — 55/55 tests passed.
- Client (`billing_notice_screen.dart`) requires no changes: it already
  calls `createStripeCheckoutSession` with `disclaimerAccepted: true` and
  reads `result.data['sessionUrl']`, which the v2 function still returns.

## Automated Deployment (New)

Added `.github/workflows/deploy-functions.yml`: triggers on pushes to
`pwa-production` that touch `functions/**`, `firestore.rules`,
`firebase.json`, or `.firebaserc` (also runnable manually via
"workflow_dispatch"). It installs function dependencies and, only if a
repo secret named `FIREBASE_TOKEN` is present, runs
`firebase deploy --only firestore:rules` and
`firebase deploy --only functions` non-interactively. If the secret is
missing it logs a warning and skips deployment (it never fails the run).

To let this workflow deploy automatically, run once, from a machine with
access to the real project:

```powershell
firebase login:ci
# copy the printed token, then:
gh secret set FIREBASE_TOKEN --repo Appdeveloper365/OmniToolkit-app
# (paste the token when prompted)
```

Also still required — set the Stripe secrets in Secret Manager (used at
Cloud Functions runtime, not by this CI workflow):

```powershell
firebase functions:secrets:set STRIPE_SECRET_KEY --project omnitoolkit-b7de8
firebase functions:secrets:set STRIPE_WEBHOOK_SECRET --project omnitoolkit-b7de8
firebase functions:secrets:set STRIPE_PRICE_ID --project omnitoolkit-b7de8
```
## Not Changed

- `BTIM_OmniToolkit.msix` / Windows worktree — untouched, per instructions.
- No new Firebase project was created; the existing `omnitoolkit-b7de8`
  project (already referenced by `lib/firebase_options.dart`) is reused.
- No Stripe secret values were invented or committed anywhere in source
  control — they must be supplied via `firebase functions:secrets:set`
  by someone with the actual Stripe dashboard credentials.