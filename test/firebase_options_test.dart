import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/firebase_options.dart';

void main() {
  test('Android uses native Firebase initialization', () {
    expect(
      DefaultFirebaseOptions.shouldUseNativeAndroidInitialization(
        isWeb: false,
        platform: TargetPlatform.android,
      ),
      isTrue,
    );
  });

  test('Web does not use native Android Firebase initialization', () {
    expect(
      DefaultFirebaseOptions.shouldUseNativeAndroidInitialization(
        isWeb: true,
        platform: TargetPlatform.android,
      ),
      isFalse,
    );
  });

  test('Desktop does not use native Android Firebase initialization', () {
    expect(
      DefaultFirebaseOptions.shouldUseNativeAndroidInitialization(
        isWeb: false,
        platform: TargetPlatform.windows,
      ),
      isFalse,
    );
  });
}
