import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
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

  static const FirebaseOptions android = FirebaseOptions(
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
