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
    apiKey: 'AIzaSyDIPSQcYjNQA1lvig3yLcBRVrMCL-vTJE0',
    authDomain: 'omnitoolkit-b7de8.firebaseapp.com',
    projectId: 'omnitoolkit-b7de8',
    storageBucket: 'omnitoolkit-b7de8.firebasestorage.app',
    messagingSenderId: '56339667385',
    appId: '1:56339667385:web:0bdb26c2f157b9f9c2be68',
  );

  static FirebaseOptions get android {
    // Use environment variables with sensible fallbacks
    // If environment variables are not set, use web fallback credentials
    return FirebaseOptions(
      apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY',
          defaultValue: 'AIzaSyDIPSQcYjNQA1lvig3yLcBRVrMCL-vTJE0'),
      appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID',
          defaultValue: '1:56339667385:web:0bdb26c2f157b9f9c2be68'),
      messagingSenderId: String.fromEnvironment(
          'FIREBASE_ANDROID_MESSAGING_SENDER_ID',
          defaultValue: '56339667385'),
      projectId: String.fromEnvironment('FIREBASE_ANDROID_PROJECT_ID',
          defaultValue: 'omnitoolkit-b7de8'),
      storageBucket: String.fromEnvironment('FIREBASE_ANDROID_STORAGE_BUCKET',
          defaultValue: 'omnitoolkit-b7de8.firebasestorage.app'),
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
    return 'Firebase initialization failed. Please verify the configured Firebase options for this platform.';
  }
}
