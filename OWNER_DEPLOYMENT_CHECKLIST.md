# OmniToolkit PWA — Firebase Functions + Stripe Deployment Checklist
(Owner-run only. Requires real Firebase login and real Stripe dashboard access.)

Target: https://appdeveloper365.github.io/OmniToolkit-app/ (repo `Appdeveloper365/OmniToolkit-app`, branch `pwa-production`)
Firebase Project: `omnitoolkit-b7de8`
Do NOT run any of this against `BTIM_OmniToolkit.msix` — it is a separate, unrelated product.

---

## 0. Prerequisites

- Node.js 18+ and the Firebase CLI available (`npx firebase-tools` works with no global install).
- Owner-level access to the `omnitoolkit-b7de8` Firebase project (Blaze/pay-as-you-go plan — required for Cloud Functions calling out to Stripe).
- Owner-level access to the Stripe Dashboard (test mode is fine to start).
- Local clone of the `pwa-production` branch:
  ```powershell
  git clone https://github.com/Appdeveloper365/OmniToolkit-app.git
  cd OmniToolkit-app
  git checkout pwa-production
  ```

---

## 1. Exact Firebase Commands Required

```powershell
# 1a. Install the CLI (or use npx for every command below instead)
npm install -g firebase-tools

# 1b. Authenticate interactively (opens a browser)
firebase login

# 1c. Confirm the active project matches .firebaserc
firebase use omnitoolkit-b7de8

# 1d. Set required secrets (prompts you to paste each value — see Section 2/3)
firebase functions:secrets:set STRIPE_SECRET_KEY
firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
firebase functions:secrets:set STRIPE_PRICE_ID

# 1e. Install function dependencies
cd functions
npm install
cd ..

# 1f. Deploy Firestore security rules
firebase deploy --only firestore:rules

# 1g. Deploy the Cloud Functions
firebase deploy --only functions
```

Optional, to enable automatic deploys via the existing GitHub Actions workflow
(`.github/workflows/deploy-functions.yml`) instead of running step 1g by hand every time:

```powershell
firebase login:ci
# copy the printed CI token, then:
gh secret set FIREBASE_TOKEN --repo Appdeveloper365/OmniToolkit-app
```

---

## 2. Exact Firebase Secrets Required

Set via `firebase functions:secrets:set <NAME>` (Firebase Secret Manager — never commit these to source):

| Secret name             | Purpose                                                    |
|--------------------------|-------------------------------------------------------------|
| `STRIPE_SECRET_KEY`      | Server-side Stripe API key used to create Checkout Sessions |
| `STRIPE_WEBHOOK_SECRET`  | Verifies the signature of incoming Stripe webhook events    |
| `STRIPE_PRICE_ID`        | The Stripe Price ID for the Lifetime Membership product     |

No other Firebase secrets are required by the current backend. (`APP_BASE_URL` is optional and falls back to `https://appdeveloper365.github.io/OmniToolkit-app` if unset — only set it via `firebase functions:config:set app.base_url=...` if you need to override it.)

---

## 3. Exact Stripe Secrets Required

Retrieve these from the Stripe Dashboard before running the commands in Section 1:

| Value                     | Where to find it in Stripe Dashboard                                             | Goes into Firebase secret |
|----------------------------|-----------------------------------------------------------------------------------|-----------------------------|
| Secret key (`sk_test_...` or `sk_live_...`) | Developers → API keys → Secret key                              | `STRIPE_SECRET_KEY`        |
| Webhook signing secret (`whsec_...`)        | Developers → Webhooks → (your endpoint, created in Section 5) → Signing secret | `STRIPE_WEBHOOK_SECRET`    |
| Price ID (`price_...`)                      | Product catalog → Lifetime Membership product → Pricing → Price ID              | `STRIPE_PRICE_ID`          |

Use test-mode keys (`sk_test_...`) first to validate the full flow before switching to live keys.

---

## 4. Exact GitHub Secret Names Required

Only needed if you want the existing CI workflow (`.github/workflows/deploy-functions.yml`) to deploy automatically on every push to `pwa-production` that touches `functions/**`, `firestore.rules`, `firebase.json`, or `.firebaserc`:

| GitHub secret name | How to generate it                              | Purpose                                                   |
|----------------------|--------------------------------------------------|-------------------------------------------------------------|
| `FIREBASE_TOKEN`     | `firebase login:ci` (prints the token to paste)  | Lets GitHub Actions run `firebase deploy` non-interactively |

Set it with:
```powershell
gh secret set FIREBASE_TOKEN --repo Appdeveloper365/OmniToolkit-app
```

Note: Stripe secrets (`STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `STRIPE_PRICE_ID`) are **not** GitHub secrets — they live only in Firebase Secret Manager (Section 2), because Cloud Functions read them at runtime, not GitHub Actions.

---

## 5. Exact Order of Deployment

1. `firebase login` (Section 1b).
2. `firebase use omnitoolkit-b7de8` (Section 1c).
3. Retrieve the three Stripe values (Section 3).
4. `firebase functions:secrets:set STRIPE_SECRET_KEY` (Section 1d).
5. `firebase functions:secrets:set STRIPE_WEBHOOK_SECRET` — **temporary placeholder value is fine here**; you don't have the real webhook signing secret until after the endpoint exists in Stripe (step 8 below creates it). Re-run this command in step 9 with the real value.
6. `firebase functions:secrets:set STRIPE_PRICE_ID` (Section 1d).
7. `cd functions && npm install && cd ..` (Section 1e).
8. `firebase deploy --only firestore:rules` (Section 1f).
9. `firebase deploy --only functions` (Section 1g) — this deploys `createStripeCheckoutSession`, `stripeWebhook`, `checkEntitlementByEmail`, and `checkEntitlementForSignedInUser`, and prints their live HTTPS URLs.
10. Copy the printed `stripeWebhook` URL. In Stripe Dashboard → Developers → Webhooks → Add endpoint:
    - Endpoint URL: the printed `stripeWebhook` URL.
    - Event to send: `checkout.session.completed`.
    - Save, then copy the newly generated Signing secret (`whsec_...`).
11. Re-run: `firebase functions:secrets:set STRIPE_WEBHOOK_SECRET` with the real signing secret from step 10.
12. Re-run: `firebase deploy --only functions` so the function picks up the corrected secret.
13. (Optional) `firebase login:ci` + `gh secret set FIREBASE_TOKEN` to enable automatic future deploys (Section 4).

---

## 6. Exact Verification Steps After Deployment

### 6a. Function URLs return HTTP 200/expected response (not 404)
The four functions are callable (`onCall`) except `stripeWebhook`, which is an HTTP endpoint. Callable functions reject unauthenticated/malformed GET requests with a 4xx JSON error rather than a plain 404 — that JSON error response (not a 404 "Not Found") is what confirms the function *exists*:
```powershell
# Expect a Firebase JSON error body (e.g. 400/401/403), NOT a bare 404 page:
curl.exe -i https://us-central1-omnitoolkit-b7de8.cloudfunctions.net/createStripeCheckoutSession
curl.exe -i https://us-central1-omnitoolkit-b7de8.cloudfunctions.net/checkEntitlementByEmail
curl.exe -i https://us-central1-omnitoolkit-b7de8.cloudfunctions.net/checkEntitlementForSignedInUser

# stripeWebhook: expect 400 "Webhook Error: No signatures found..." (proves it exists and validates signatures)
curl.exe -i https://us-central1-omnitoolkit-b7de8.cloudfunctions.net/stripeWebhook
```
A true 404 means the function is still not deployed — re-check `firebase deploy --only functions` output for errors.

### 6b. Firebase Console confirmation
Firebase Console → Functions → confirm all 4 functions are listed with a green/healthy status and recent deploy timestamp.

### 6c. Stripe Checkout Session creation works end-to-end
On the live site:
1. Go to https://appdeveloper365.github.io/OmniToolkit-app/
2. Settings → Account & Billing → Before Checkout screen appears.
3. Check the disclaimer checkbox → tap **Next**.
4. Expected: browser redirects to a real Stripe Checkout page (`checkout.stripe.com/...`), not an error snackbar.
5. Complete a test-mode purchase using Stripe's test card `4242 4242 4242 4242`, any future expiry, any CVC.
6. Expected: redirect back to `.../#/payment-success?session_id=...`.

### 6d. Webhook fulfillment works
1. Stripe Dashboard → Developers → Webhooks → your endpoint → confirm the `checkout.session.completed` event from the test purchase shows a `200` response.
2. Firebase Console → Firestore Data → `entitlements/{the test purchase email}` → confirm a document exists with `hasLifetimeAccess: true` and `paymentStatus: "paid"`.

### 6e. Full navigation flow confirmation
Confirm the exact path works with no fallback to Calendar and no forced login:
```
Settings → Account & Billing → Before Checkout → Next → Stripe Checkout → payment-success
```

### 6f. Firebase Functions logs are clean
```powershell
firebase functions:log --only createStripeCheckoutSession
firebase functions:log --only stripeWebhook
```
Confirm no `failed-precondition`, `internal`, or secret-related errors during the test purchase.

---

## Reference: Current Function Names (already implemented in `functions/index.js`)

| Function | Type | Purpose |
|---|---|---|
| `createStripeCheckoutSession` | Callable | Creates the Stripe Checkout Session (equivalent to "createCheckoutSession") |
| `stripeWebhook` | HTTPS | Verifies and fulfills `checkout.session.completed` events |
| `checkEntitlementByEmail` | Callable | Public lookup of membership status by purchase email |
| `checkEntitlementForSignedInUser` | Callable | Matches a signed-in account email against a purchase (equivalent to an "entitlementSync" check) |

There is currently no `customerPortal` function in this codebase — add one only if/when a self-service subscription-management portal is required (not needed for the current one-time Lifetime Membership purchase model).