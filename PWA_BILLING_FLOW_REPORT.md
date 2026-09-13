# PWA Billing Flow Report

## Root cause

Settings previously navigated to `/account`, but the PWA authentication cleanup removed the account and billing screens. The app's catch-all route returned `MainNavigation`, whose first tab is Calendar. That made Account & Billing appear to redirect to Calendar.

## Current route flow

`Settings -> /billing-notice -> Billing Notice -> Next -> createStripeCheckoutSession -> Stripe Checkout`

The legacy `/account` path is also mapped to Billing Notice so old links cannot fall through to Calendar.

## Files modified

- `lib/core/settings/settings_screen.dart` — Account & Billing now opens `/billing-notice`.
- `lib/main.dart` — initializes Firebase without auth gating and explicitly routes `/billing-notice` and `/account` to Billing Notice.
- `lib/screens/billing_notice_screen.dart` — displays the required notice and launches Stripe Checkout from Next.
- `functions/index.js` — validates the requested billing email against the authenticated Firebase email before creating Checkout, while retaining the configured Stripe price ID and webhook checks.
- `pubspec.yaml` / `pubspec.lock` — restores Firebase Core/Auth, Cloud Functions, and URL Launcher client dependencies needed for checkout.
- `PWA_BILLING_FLOW_REPORT.md` — this report.

## Stripe validation

The client calls `createStripeCheckoutSession` with the authenticated user's normalized email. The callable backend uses the authenticated token email, rejects a mismatched requested email, and passes the verified email to Stripe as `customer_email` and metadata. The configured `STRIPE_PRICE_ID` remains the product price source. The webhook continues to require matching account/billing emails before entitlement fulfillment.

Repository validation passed: `flutter analyze`, serial `flutter test`, `flutter build web --release --base-href "/OmniToolkit-app/"`, and `node --check functions/index.js`.

Live checkout still requires a signed-in Firebase session and deployed Firebase Function secrets (`STRIPE_SECRET_KEY`, `STRIPE_PRICE_ID`, `STRIPE_WEBHOOK_SECRET`). Those external settings cannot be verified from source alone.