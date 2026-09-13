# Authentication Removal Report

## Result

OmniToolkit now launches directly to the dashboard. Google Sign-In, Firebase Authentication, the login/onboarding experience, trials, and entitlement route guards have been removed.

## Deleted files

- `lib/core/auth/auth_provider.dart`
- `lib/core/auth/user_model.dart`
- `lib/core/navigation/route_guard.dart`
- `lib/core/widgets/trial_banner.dart`
- `lib/screens/login_screen.dart`
- `lib/screens/account_screen.dart`
- `test/route_guard_test.dart`
- `test/firebase_options_test.dart`
- `GOOGLE_SIGNIN_FIX_REPORT.md`
- `WINDOWS_GOOGLE_AUTH_FIX.md`
- `BEFORE_AFTER_COMPARISON.md`

## Removed packages

- `google_sign_in`
- `firebase_auth`
- `cloud_firestore`
- `firebase-admin` (Cloud Functions backend)

The retained Firebase packages are `firebase_core` and `cloud_functions`, required by the existing Stripe Checkout callable used by the Windows premium purchase screen.

## Remaining dependencies

Flutter app dependencies: cupertino_icons, flutter_riverpod, http, intl, timezone, shared_preferences, sqflite, sqflite_common_ffi, path, path_provider, just_audio, media_kit, just_audio_media_kit, media_kit_libs_windows_audio, math_expressions, sqflite_common_ffi_web, firebase_core, cloud_functions, and url_launcher.

Cloud Functions dependencies: firebase-functions and stripe. The direct firebase-admin dependency was removed.

## Checkout backend

functions/index.js no longer requires Firebase Authentication, user records, or Firestore. It creates a Stripe Checkout session without account binding and verifies completed Stripe webhook events.
## Routes

Removed: `/login`, `/account`, and all authentication/entitlement redirects.

Retained: `/` (dashboard), `/share`, `/pricing`, `/payment-success`, and `/payment-cancelled`.

## Premium behavior

The Settings screen provides a **Premium Access** entry that opens the Stripe checkout flow. No login is required to access OmniToolkit or start checkout.

## Platform note

This workspace has no `android/` target, so it cannot produce an APK variant. No Android-specific free-build configuration exists to change.

## Validation

- `flutter analyze`: passed with no issues.
- `flutter test`: passed (57 tests).
- `flutter build windows --release`: passed.
- `flutter pub run msix:create`: passed.
- Release executable launched successfully without an authentication gate.
- MSIX artifact: `build/msix/BTIM_OmniToolkit.msix` (27.82 MB).

