# PWA Anonymous Checkout Report

## Root Cause
Both the client (`billing_notice_screen.dart`) and server (`createStripeCheckoutSession` in
`functions/index.js`) required an authenticated Firebase user before Stripe Checkout could
start. The app's sign-in UI was removed in a prior change, so no user could ever reach an
authenticated state, and every checkout attempt failed with "Authenticated email account is
required before checkout".

## Files Modified
- `functions/index.js`
  - `createStripeCheckoutSession`: `context.auth` is now optional. Requires
    `data.disclaimerAccepted === true` from the client call (no Firestore lookup). Uses
    `context.auth?.uid` / `context.auth?.token?.email` only as optional linking hints; rejects
    only if a signed-in email and a supplied `billingEmail` disagree. Lets Stripe Checkout
    collect the purchaser's email when no user is signed in (`customer_creation: "always"`).
  - `stripeWebhook`: fulfillment no longer requires a `uid`. Entitlement is written to
    `entitlements/{normalizedEmail}` (email, paymentStatus, hasLifetimeAccess, premium_active,
    purchaseDate, stripeCustomerId, stripeSessionId, purchaseEmail, linkedUid). If a `uid` is
    present it's mirrored into `users/{uid}` as before (best effort).
  - Added `checkEntitlementForSignedInUser` (auth required): compares the signed-in account
    email to `entitlements/{email}` and self-heals `linkedUid` on match.
  - Added `checkEntitlementByEmail` (public, no auth): lets a visitor check/restore membership
    status by typing the email used at checkout, since the app currently has no sign-in UI.
- `lib/screens/billing_notice_screen.dart` — removed the "must be signed in" block. Shows the
  billing notice, a required disclaimer checkbox, and a "Next" button that calls
  `createStripeCheckoutSession` with `disclaimerAccepted: true` (plus the signed-in email only
  if one exists) and opens the returned Stripe Checkout URL.
- `lib/screens/entitlement_check_screen.dart` (new) — calls `checkEntitlementForSignedInUser`
  and shows a clear match/mismatch message, satisfying "when a user later signs in, compare
  emails and explain mismatches".
- `lib/core/settings/settings_screen.dart` — added a "Membership Status" entry point to
  `/membership-status`.
- `lib/main.dart` — registered the `/membership-status` route.
- `firestore.rules` — added `entitlements/{email}`: all writes denied to clients (Admin SDK
  only, via Cloud Functions); reads allowed only to a signed-in user for their own account
  email.

## Updated Purchase Flow
```
Visitor (no login required)
  → Settings → Account & Billing
  → Billing Notice screen (disclaimer checkbox)
  → Next
  → createStripeCheckoutSession({ disclaimerAccepted: true })
  → Stripe Checkout (collects purchaser email if not already known)
  → stripeWebhook fulfills → entitlements/{email} created/updated
```

## Entitlement Matching Logic
- Purchases are always keyed by the **billing email**, whether or not the purchaser was signed
  in (`entitlements/{normalizedEmail}`).
- When a user is signed in, Settings → Membership Status calls
  `checkEntitlementForSignedInUser`, which normalizes the signed-in email and looks up the same
  `entitlements/{email}` doc:
  - Match + `hasLifetimeAccess: true` → "Lifetime Membership is active".
  - Match but not yet paid → informs the user no active membership was found.
  - No document at all → explains access is linked to the billing email and to sign in with
    the exact purchase email.
- `checkEntitlementByEmail` lets anyone (even without signing in) check status by typing the
  purchase email directly, covering the "how does an anonymous purchaser check status" gap.

## Validation Results
- `node --check functions/index.js` — passes.
- `flutter analyze` — No issues found.
- `flutter test --concurrency=1` — 55/55 tests passed.
- `flutter build web --release --base-href "/OmniToolkit-app/"` — succeeded.
- Manual code review confirms `createStripeCheckoutSession` no longer throws on missing
  `context.auth`, and no code path requires a `uid` to complete a purchase.

## Known Limitation
There is still no dedicated "sign in" entry point in this app (removed previously per an
earlier requirement). "Membership Status" in Settings works for any user who becomes signed in
through some other means (e.g., a future re-introduced sign-in flow) and also supports fully
anonymous status checks via `checkEntitlementByEmail`. If a persistent sign-in UI is desired,
that is a separate follow-up task.