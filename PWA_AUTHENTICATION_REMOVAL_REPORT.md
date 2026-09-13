# PWA Authentication Removal Report

## Result

The PWA now starts directly at `MainNavigation`. No authentication provider, login gate, Google Sign-In flow, trial gate, or onboarding page runs during startup.

## Deleted files

- `lib/core/auth/auth_provider.dart`
- `lib/core/auth/user_model.dart`
- `lib/core/config/build_config.dart`
- `lib/core/navigation/route_guard.dart`
- `lib/core/widgets/trial_banner.dart`
- `lib/firebase_options.dart`
- `lib/screens/login_screen.dart`
- `lib/screens/account_screen.dart`
- `lib/screens/pricing_screen.dart`
- `lib/screens/payment_success_screen.dart`
- `lib/screens/payment_cancelled_screen.dart`
- `test/firebase_options_test.dart`
- `test/route_guard_test.dart`
- `GOOGLE_SIGNIN_FIX_REPORT.md`

## Removed routes

- `/login`
- `/account`
- `/pricing`
- `/payment-success`
- `/payment-cancelled`

The `/share` Web Share Target route remains. Any other route opens `MainNavigation`.

## Startup change

Before: `App -> auth startup/provider -> LoginScreen -> Google Sign-In -> Dashboard`

After: `App -> MainNavigation dashboard`

Timezone and local asset initialization remain, but they do not perform authentication checks.

## Removed dependencies

The PWA manifest no longer includes Firebase Auth, Google Sign-In, Firestore, Cloud Functions, or URL launcher client packages.

## Verification search

The tracked PWA source contains no occurrences of:

- `google_sign_in`
- `FirebaseAuth`
- `signInWithGoogle`
- `AuthGate`
- `LoginScreen`
- `TrialScreen`
- `onboarding`
- `Welcome to OmniToolkit`
- `Continue with Google`
- `7-day free trial`