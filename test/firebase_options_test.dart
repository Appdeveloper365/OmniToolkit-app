/// FILE: test/firebase_options_test.dart
///
/// Regression guard for the Firebase configuration used by main().
///
/// A previous "security" change replaced the bundled Firebase web options with
/// `String.fromEnvironment()` lookups that had no default values. That silently
/// produced an app whose Firebase initialization always failed, disabling
/// billing, membership and entitlement features in every plain
/// `flutter build web --release`. These tests make that failure loud again.
import 'package:flutter/foundation.dart' show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/firebase_options.dart';

void main() {
  // `flutter test` reports TargetPlatform.android by default, so the platform
  // is pinned explicitly for each scenario. Native Android options are
  // intentionally empty (Android is no longer shipped from this repository).
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('DefaultFirebaseOptions.web', () {
    test('resolves a usable configuration without --dart-define', () {
      expect(DefaultFirebaseOptions.web.apiKey, isNotEmpty);
      expect(DefaultFirebaseOptions.web.appId, isNotEmpty);
      expect(DefaultFirebaseOptions.web.projectId, isNotEmpty);
      expect(DefaultFirebaseOptions.web.authDomain, isNotEmpty);
      expect(DefaultFirebaseOptions.web.messagingSenderId, isNotEmpty);
    });

    test('targets the OmniToolkit Firebase project', () {
      expect(DefaultFirebaseOptions.web.projectId, 'omnitoolkit-b7de8');
      expect(
        DefaultFirebaseOptions.web.authDomain,
        'omnitoolkit-b7de8.firebaseapp.com',
      );
    });

    test('reports the options as configured on a shipped desktop target', () {
      // main() skips Firebase.initializeApp entirely when this is false.
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(DefaultFirebaseOptions.currentPlatform.projectId,
          DefaultFirebaseOptions.web.projectId);
      expect(DefaultFirebaseOptions.isConfigured, isTrue);
    });
  });

  group('DefaultFirebaseOptions.android', () {
    test('has no baked-in defaults and is therefore unconfigured', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(DefaultFirebaseOptions.currentPlatform.projectId, isEmpty);
      expect(DefaultFirebaseOptions.isConfigured, isFalse);
    });
  });

  group('DefaultFirebaseOptions.shouldUseNativeAndroidInitialization', () {
    test('is false on the web', () {
      expect(
        DefaultFirebaseOptions.shouldUseNativeAndroidInitialization(
          isWeb: true,
          platform: TargetPlatform.android,
        ),
        isFalse,
      );
    });

    test('is true only for native Android', () {
      expect(
        DefaultFirebaseOptions.shouldUseNativeAndroidInitialization(
          isWeb: false,
          platform: TargetPlatform.android,
        ),
        isTrue,
      );
      expect(
        DefaultFirebaseOptions.shouldUseNativeAndroidInitialization(
          isWeb: false,
          platform: TargetPlatform.windows,
        ),
        isFalse,
      );
      expect(
        DefaultFirebaseOptions.shouldUseNativeAndroidInitialization(
          isWeb: false,
          platform: TargetPlatform.macOS,
        ),
        isFalse,
      );
    });
  });

  group('DefaultFirebaseOptions.describeInitializationFailure', () {
    test('mentions the build-time override off Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      final message = DefaultFirebaseOptions.describeInitializationFailure(
        Exception('boom'),
      );
      expect(message, contains('--dart-define'));
    });

    test('points Android builds at google-services.json', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final message = DefaultFirebaseOptions.describeInitializationFailure(
        Exception('boom'),
      );
      expect(message, contains('google-services.json'));
    });
  });
}
