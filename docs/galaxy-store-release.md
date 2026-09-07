# OmniToolkit Galaxy Store Release Setup

## Android package

Use this exact Android package name when registering the app in Firebase and Samsung Seller Portal:

```text
com.omnitoolkit.app
```

## Firebase Android app registration

The Firebase Android app must be created in the existing Firebase project:

```text
omnitoolkit-b7de8
```

Register an Android app with package name:

```text
com.omnitoolkit.app
```

Add these release-signing fingerprints to the Android app in Firebase Project settings:

```text
SHA-1:   C3:A6:A5:CC:91:57:EA:38:53:49:FC:9B:E3:AC:81:FE:9F:EA:A5:0E
SHA-256: E6:0C:59:2E:B4:58:96:5B:71:B3:DA:C6:33:59:29:5D:D4:1F:4A:AA:F2:F7:5F:9D:B3:58:00:8A:CE:FD:5B:BF
```

After registering the Android app, download `google-services.json` from Firebase and place it at:

```text
android/app/google-services.json
```

Do not commit `google-services.json`; it is intentionally ignored by `.gitignore`.

## Firebase Google Sign-In

In Firebase Console:

1. Open Authentication > Sign-in method.
2. Enable Google provider.
3. Confirm the Android app `com.omnitoolkit.app` is listed under Project settings > Your apps.
4. Confirm the SHA-1 and SHA-256 fingerprints above are saved on that Android app.
5. Download a fresh `google-services.json` after adding fingerprints.

## GitHub Actions Firebase Android dart-defines

After the Android Firebase app is created, add these GitHub repository secrets from the generated Android Firebase configuration:

```text
FIREBASE_ANDROID_API_KEY
FIREBASE_ANDROID_APP_ID
FIREBASE_ANDROID_MESSAGING_SENDER_ID
FIREBASE_ANDROID_PROJECT_ID
FIREBASE_ANDROID_STORAGE_BUCKET
GOOGLE_SERVICES_JSON_BASE64
```

The pipeline passes the Firebase values into the Android build with `--dart-define` and decodes `GOOGLE_SERVICES_JSON_BASE64` to `android/app/google-services.json`, so Android uses the Android Firebase app registration instead of the web app ID.

## Release keystore

A Galaxy Store release keystore was generated locally at:

```text
C:\Users\bala\.omnitoolkit-release\omnitoolkit-galaxy-store.jks
```

A local Gradle signing file was generated at:

```text
C:\Users\bala\omnitoolkit-pwa-publishing-file\android\key.properties
```

Both paths are intentionally ignored by Git. Keep a secure backup of the keystore and passwords. Losing the keystore can prevent future updates to the Galaxy Store app.

## GitHub release-signing secrets

These GitHub Actions secrets have been configured for release-signed CI builds:

```text
ANDROID_KEYSTORE_BASE64
ANDROID_KEYSTORE_PASSWORD
ANDROID_KEY_ALIAS
ANDROID_KEY_PASSWORD
```

## Build commands

Local release APK:

```powershell
flutter build apk --release --dart-define=IS_STORE_BUILD=true
```

Local release AAB:

```powershell
flutter build appbundle --release --dart-define=IS_STORE_BUILD=true
```

GitHub Actions builds both artifacts automatically and publishes them to:

```text
https://appdeveloper365.github.io/OmniToolkit-app/downloads/productivity-radio.apk
https://appdeveloper365.github.io/OmniToolkit-app/downloads/productivity-radio.aab
```

## Web Service-Worker Configuration for Downloads

**IMPORTANT:** The `/OmniToolkit-app/downloads/` directory must bypass the SPA service-worker fallback.

The service-worker must NOT route APK/AAB download requests to `index.html`. If this bypass is not configured correctly:
- APK/AAB URLs will return `index.html` instead of the binary file
- Downloads will fail with corruption errors
- Browser will try to run the app instead of downloading the file

**Configuration Required:**
- Ensure `web/service-worker.js` excludes `/downloads/` from the offline-first fallback strategy
- Verify that requests to `/downloads/*` routes are never rewritten to `index.html`
- Test downloads directly: `curl -I https://appdeveloper365.github.io/OmniToolkit-app/downloads/productivity-radio.apk`
- Verify response is `application/vnd.android.package`, not `text/html`

## Store-safe monetization behavior

The store build must show only this access message before entitlement:

```text
Premium account required. Please log in using an account activated on our official website.
```

The store build must not show direct Stripe checkout, price references, buy buttons, or purchase marketing language. Users who paid on the official web app retain access by signing into the same Google/Firebase account; Android checks the same Firestore entitlement fields used by web:

```text
paymentStatus
hasLifetimeAccess
premium_active
```
