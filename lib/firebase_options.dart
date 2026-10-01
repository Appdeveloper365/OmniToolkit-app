import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb, visibleForTesting;

class DefaultFirebaseOptions {
  /// Firebase configuration is supplied at **build time only** - no Firebase
  /// identifier is embedded in this source file.
  ///
  /// Provide the values either per flag:
  ///   flutter build web --release \
  ///     --dart-define=FIREBASE_WEB_API_KEY=... \
  ///     --dart-define=FIREBASE_WEB_PROJECT_ID=...
  ///
  /// or, preferably, from a local (git-ignored) config file:
  ///   flutter build web --release \
  ///     --dart-define-from-file=tool/firebase_defines.json
  ///
  /// See `tool/firebase_defines.example.json` for the required keys and
  /// `tool/build_web.sh` for the helper used by local builds. CI does the same
  /// thing from repository variables/secrets (see .github/workflows/deploy.yml).
  ///
  /// A build without these values still runs: `main()` checks [isConfigured]
  /// and skips Firebase initialization, leaving the local-first dashboard,
  /// calendar, calculator, lookup and password modules fully functional while
  /// billing/entitlement features report themselves as unavailable.
  ///
  /// Access control never depends on these values being secret - it is enforced
  /// by Firebase Security Rules (see firestore.rules) and by Cloud Functions.
  ///
  @visibleForTesting
  static bool shouldUseNativeAndroidInitialization({
    required bool isWeb,
    required TargetPlatform platform,
  }) =>
      !isWeb && platform == TargetPlatform.android;

  static bool get useNativeAndroidInitialization =>
      shouldUseNativeAndroidInitialization(
        isWeb: kIsWeb,
        platform: defaultTargetPlatform,
      );

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return web;
    }
  }

  /// Web/desktop options. Every value is empty unless supplied at build time
  /// via --dart-define / --dart-define-from-file (see class docs above).
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY'),
    authDomain: String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN'),
    projectId: String.fromEnvironment('FIREBASE_WEB_PROJECT_ID'),
    storageBucket: String.fromEnvironment('FIREBASE_WEB_STORAGE_BUCKET'),
    messagingSenderId: String.fromEnvironment('FIREBASE_WEB_MESSAGING_SENDER_ID'),
    appId: String.fromEnvironment('FIREBASE_WEB_APP_ID'),
    measurementId: String.fromEnvironment('FIREBASE_WEB_MEASUREMENT_ID'),
  );

  /// Android builds are no longer shipped from this repository. The Android
  /// options use the same build-time mechanism as [web] and have no baked-in
  /// defaults; supply them with --dart-define (or google-services.json) if
  /// Android support is revived.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_ANDROID_MESSAGING_SENDER_ID',
    ),
    projectId: String.fromEnvironment('FIREBASE_ANDROID_PROJECT_ID'),
    storageBucket: String.fromEnvironment('FIREBASE_ANDROID_STORAGE_BUCKET'),
  );

  /// Whether the resolved options contain the minimum fields needed to start
  /// Firebase. A build with `--dart-define`s that blank these out should skip
  /// initialization instead of throwing inside `Firebase.initializeApp`.
  static bool get isConfigured {
    final options = currentPlatform;
    return options.apiKey.isNotEmpty &&
        options.projectId.isNotEmpty &&
        options.appId.isNotEmpty;
  }

  static Future<FirebaseApp> initializeFirebaseApp() {
    if (useNativeAndroidInitialization) {
      return Firebase.initializeApp();
    }
    return Firebase.initializeApp(options: currentPlatform);
  }

  static String describeInitializationFailure(Object _) {
    if (useNativeAndroidInitialization) {
      return 'Android Firebase initialization failed. Confirm android/app/google-services.json matches com.omnitoolkit.app and the Android Firebase secrets were supplied for this build.';
    }
    return 'Firebase initialization failed. Please verify the configured Firebase options for this platform. Ensure all FIREBASE_* environment variables are set via --dart-define during build.';
  }
}
