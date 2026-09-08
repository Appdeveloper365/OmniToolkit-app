# Why "Next" Does Not Reach Stripe Checkout (Diagnosis)

## Root Cause (confirmed live)
The Cloud Functions backend (`createStripeCheckoutSession`, `stripeWebhook`,
`checkEntitlementByEmail`, `checkEntitlementForSignedInUser`) has **never
actually been deployed** to the `omnitoolkit-b7de8` Firebase project.

Verified directly against the live endpoints:
```
GET https://us-central1-omnitoolkit-b7de8.cloudfunctions.net/createStripeCheckoutSession -> 404
GET https://us-central1-omnitoolkit-b7de8.cloudfunctions.net/stripeWebhook              -> 404
```
A 404 at the Cloud Functions URL means the function does not exist on the
project yet — this is not a Stripe approval issue. Stripe does not need to
"approve" anything for test-mode checkout sessions to be created; that only
matters for going live with real payment methods later. The blocker is
that the backend code (which I wrote/updated in this worktree) was never
pushed to Firebase's servers.

Why it was never deployed: deploying requires running `firebase deploy`
with a real, interactively-obtained Firebase login (or a CI token) plus the
Stripe secret values in Firebase Secret Manager. This sandboxed agent
environment has no browser for OAuth and no Firebase/Stripe credentials
anywhere in the repo or environment, so it cannot perform that step itself
— confirmed again this session: `firebase login:ci` fails immediately with
"Cannot run login:ci in non-interactive mode" here.

## Client-Side Bug Also Fixed
Separately, `lib/screens/billing_notice_screen.dart` only caught
`FirebaseFunctionsException`. When the callable doesn't exist at all (as is
currently the case), the Firebase Functions SDK can throw a different
exception type, which was falling through uncaught — this is very likely
why the button visually did "nothing" instead of showing an error message.
Fixed to:
- Catch any exception type, not just `FirebaseFunctionsException`.
- Show a clear, specific message per error code (`not-found`,
  `failed-precondition`, `unauthenticated`, `invalid-argument`, etc.)
  instead of silently failing.

Once the backend is deployed, this fix means any future misconfiguration
will show a clear on-screen error instead of appearing to do nothing.

## What YOU Need To Do To Fix This For Real

These steps require real credentials (Firebase login + Stripe dashboard
keys) that only you have access to — they cannot be run by this agent:

```powershell
cd C:\Users\bala\omnitoolkit-pwa

# 1. Log in interactively (opens a browser)
firebase login

# 2. Confirm/select the project (already set as default in .firebaserc)
firebase use omnitoolkit-b7de8

# 3. Set the three Stripe secrets (paste real values when prompted)
firebase functions:secrets:set STRIPE_SECRET_KEY
firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
firebase functions:secrets:set STRIPE_PRICE_ID

# 4. Deploy the backend
firebase deploy --only functions
firebase deploy --only firestore:rules
```

After step 4, take the printed `stripeWebhook` URL and add it in the
Stripe Dashboard → Webhooks → Add endpoint, listening for
`checkout.session.completed`.

### To make future deploys automatic (recommended)
A CI workflow (`.github/workflows/deploy-functions.yml`) already exists and
will deploy functions on every push to `pwa-production` automatically —
it just needs one secret added once:

```powershell
firebase login:ci
# copy the printed token, then:
gh secret set FIREBASE_TOKEN --repo Appdeveloper365/OmniToolkit-app
# (paste the token when prompted)
```

Once `FIREBASE_TOKEN` exists as a repo secret, this session's next push (or
any push touching `functions/**`) will deploy the backend automatically —
no more manual `firebase deploy` needed.

## Validation Performed This Session
- Confirmed via direct HTTP requests that none of the 4 Cloud Functions
  exist on the live project (404 for all).
- Confirmed `firebase login:ci` cannot run non-interactively in this
  environment (expected, and by design — real credentials are never
  fabricated).
- Fixed and validated the client error-handling bug:
  `flutter analyze` — No issues found.
  `flutter test --concurrency=1` — 55/55 passed.
- Confirmed Settings → Account & Billing → Billing Notice screen still
  renders correctly and the "Next" button now surfaces the real backend
  error message ("Checkout is not available yet...") instead of silently
  doing nothing, once deployed this message path will only appear for
  genuine transient failures.