import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb, visibleForTesting;

class DefaultFirebaseOptions {
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
    apiKey: String.fromEnvironment('FIREBASE_WEB_API_KEY'),
    authDomain: String.fromEnvironment('FIREBASE_WEB_AUTH_DOMAIN'),
    projectId: String.fromEnvironment('FIREBASE_WEB_PROJECT_ID'),
    storageBucket: String.fromEnvironment('FIREBASE_WEB_STORAGE_BUCKET'),
    messagingSenderId: String.fromEnvironment('FIREBASE_WEB_MESSAGING_SENDER_ID'),
    appId: String.fromEnvironment('FIREBASE_WEB_APP_ID'),
    measurementId: String.fromEnvironment('FIREBASE_WEB_MEASUREMENT_ID', defaultValue: ''),
  );

  static FirebaseOptions get android {
    return const FirebaseOptions(
      apiKey: const String.fromEnvironment('FIREBASE_ANDROID_API_KEY', defaultValue: ''),
      appId: const String.fromEnvironment('FIREBASE_ANDROID_APP_ID', defaultValue: ''),
      messagingSenderId: const String.fromEnvironment('FIREBASE_ANDROID_MESSAGING_SENDER_ID', defaultValue: ''),
      projectId: const String.fromEnvironment('FIREBASE_ANDROID_PROJECT_ID', defaultValue: ''),
      storageBucket: const String.fromEnvironment('FIREBASE_ANDROID_STORAGE_BUCKET', defaultValue: ''),
    );
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