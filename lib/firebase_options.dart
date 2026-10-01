import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb, visibleForTesting;

class DefaultFirebaseOptions {
  /// Firebase web/desktop configuration for the OmniToolkit project.
  ///
  /// These values are *public client identifiers*, not secrets: Firebase ships
  /// them inside every web bundle by design, and access control is enforced by
  /// Firebase Security Rules (see firestore.rules) rather than by hiding the
  /// config. Keeping working defaults here means a plain
  /// `flutter build web --release` produces a functional app.
  ///
  /// Any of the values may still be overridden at build time for another
  /// environment, e.g.:
  ///   flutter build web --release \
  ///     --dart-define=FIREBASE_WEB_API_KEY=... \
  ///     --dart-define=FIREBASE_WEB_PROJECT_ID=...
  static const String _defaultWebApiKey =
      'AIzaSyDIPSQcYjNQA1lvig3yLcBRVrMCL-vTJE0';
  static const String _defaultWebAuthDomain =
      'omnitoolkit-b7de8.firebaseapp.com';
  static const String _defaultWebProjectId = 'omnitoolkit-b7de8';
  static const String _defaultWebStorageBucket =
      'omnitoolkit-b7de8.firebasestorage.app';
  static const String _defaultWebMessagingSenderId = '56339667385';
  static const String _defaultWebAppId =
      '1:56339667385:web:0bdb26c2f157b9f9c2be68';

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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_WEB_API_KEY',
      defaultValue: _defaultWebApiKey,
    ),
    authDomain: String.fromEnvironment(
      'FIREBASE_WEB_AUTH_DOMAIN',
      defaultValue: _defaultWebAuthDomain,
    ),
    projectId: String.fromEnvironment(
      'FIREBASE_WEB_PROJECT_ID',
      defaultValue: _defaultWebProjectId,
    ),
    storageBucket: String.fromEnvironment(
      'FIREBASE_WEB_STORAGE_BUCKET',
      defaultValue: _defaultWebStorageBucket,
    ),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_WEB_MESSAGING_SENDER_ID',
      defaultValue: _defaultWebMessagingSenderId,
    ),
    appId: String.fromEnvironment(
      'FIREBASE_WEB_APP_ID',
      defaultValue: _defaultWebAppId,
    ),
    measurementId: String.fromEnvironment('FIREBASE_WEB_MEASUREMENT_ID'),
  );

  /// Android builds are no longer shipped from this repository, so the Android
  /// options intentionally have no baked-in defaults; supply them with
  /// --dart-define (or google-services.json) if Android support is revived.
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
