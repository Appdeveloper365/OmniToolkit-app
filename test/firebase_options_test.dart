/// FILE: test/firebase_options_test.dart
///
/// Guards the Firebase configuration contract used by main().
///
/// 1. No Firebase identifier may be hardcoded in `lib/firebase_options.dart`.
///    Values are supplied per environment at build time via
///    `--dart-define` / `--dart-define-from-file` (see
///    `tool/firebase_defines.example.json` and `.github/workflows/deploy.yml`).
/// 2. The resolved options must be *all* or *nothing*: a build is either fully
///    configured (so `isConfigured` is true and main() starts Firebase) or it
///    carries nothing (so `isConfigured` is false and the app degrades to the
///    local-first modules). Half-configured builds are the bug this guards.
///
/// Note: `String.fromEnvironment` is not readable from a test file, so these
/// tests read the resolved options instead of the raw defines. That keeps them
/// meaningful both for a plain `flutter test` and for one invoked with
/// `--dart-define-from-file`.
library;

import 'dart:io';

import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/firebase_options.dart';

void main() {
  // `flutter test` reports TargetPlatform.android by default, so the platform
  // is pinned explicitly for each scenario.
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('no hardcoded Firebase identifiers in source', () {
    late String source;

    setUp(() {
      final file = File('lib/firebase_options.dart');
      expect(file.existsSync(), isTrue,
          reason: 'run tests from the package root');
      source = file.readAsStringSync();
    });

    test('contains no Firebase API key literal', () {
      // Every Firebase web API key starts with "AIza".
      expect(source, isNot(contains('AIza')));
    });

    test('contains no Firebase app-id literal', () {
      // App ids have the shape 1:<digits>:web:<hash>.
      expect(source, isNot(matches(RegExp(r'\d+:\d+:web:'))));
    });

    test('contains no Firebase host or bucket literal', () {
      expect(source, isNot(contains('firebaseapp.com')));
      expect(source, isNot(contains('firebasestorage.app')));
    });

    test('provides no defaultValue that could re-embed a credential', () {
      expect(source, isNot(contains('defaultValue')));
    });
  });

  group('DefaultFirebaseOptions.web', () {
    const options = DefaultFirebaseOptions.web;

    test('is fully supplied, or carries nothing at all', () {
      final projectId = options.projectId;
      if (projectId.isEmpty) {
        expect(options.apiKey, isEmpty, reason: 'apiKey must not be baked in');
        expect(options.appId, isEmpty, reason: 'appId must not be baked in');
        expect(options.authDomain ?? '', isEmpty);
        expect(options.messagingSenderId, isEmpty);
        expect(options.storageBucket ?? '', isEmpty);
      } else {
        expect(options.apiKey, isNotEmpty,
            reason: 'a configured build needs an apiKey');
        expect(options.appId, isNotEmpty,
            reason: 'a configured build needs an appId');
      }
    });

    test('isConfigured agrees with the resolved project id', () {
      // main() skips Firebase.initializeApp entirely when this is false.
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(DefaultFirebaseOptions.currentPlatform.projectId,
          options.projectId);
      expect(DefaultFirebaseOptions.isConfigured, options.projectId.isNotEmpty);
    });
  });

  group('DefaultFirebaseOptions.android', () {
    test('is never preconfigured', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(DefaultFirebaseOptions.currentPlatform.projectId, isEmpty);
      // Android is not shipped from this repository and its defines are never
      // supplied, so the app must always degrade gracefully there.
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
      for (final platform in <TargetPlatform>[
        TargetPlatform.windows,
        TargetPlatform.macOS,
        TargetPlatform.iOS,
        TargetPlatform.linux,
      ]) {
        expect(
          DefaultFirebaseOptions.shouldUseNativeAndroidInitialization(
            isWeb: false,
            platform: platform,
          ),
          isFalse,
          reason: '$platform must not use native Android initialization',
        );
      }
    });
  });

  group('DefaultFirebaseOptions.describeInitializationFailure', () {
    test('mentions the build-time override off Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      final message = DefaultFirebaseOptions.describeInitializationFailure(
        const FormatException('boom'),
      );
      expect(message, contains('--dart-define'));
      expect(message, contains('FIREBASE_'));
    });

    test('points Android builds at google-services.json', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final message = DefaultFirebaseOptions.describeInitializationFailure(
        const FormatException('boom'),
      );
      expect(message, contains('google-services.json'));
    });
  });
}
