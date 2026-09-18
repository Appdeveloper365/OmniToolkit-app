import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/core/membership/membership_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('MembershipState.fromData parses active device metadata', () {
    final state = MembershipState.fromData({
      'email': 'buyer@example.com',
      'emailVerified': true,
      'hasLifetimeAccess': true,
      'trialActive': false,
      'deviceLimitReached': true,
      'activeDeviceCount': 3,
      'activeDevices': [
        {
          'email': 'buyer@example.com',
          'deviceId': 'device-a',
          'platform': 'android',
          'firstSeen': '2026-09-15T10:00:00.000Z',
          'lastSeen': '2026-09-17T10:00:00.000Z',
        },
      ],
    });

    expect(state.deviceLimitReached, isTrue);
    expect(state.activeDeviceCount, 3);
    expect(state.activeDevices, hasLength(1));
    expect(state.activeDevices.first, isA<ActiveDevice>());
    expect(state.hasAccess, isFalse);
    expect(state.canUnlockRadioDirectory, isFalse);
  });

  test('MembershipState.fromCache defaults device-limit fields safely', () {
    SharedPreferences.setMockInitialValues({
      'membership.email': 'buyer@example.com',
      'membership.hasLifetimeAccess': true,
      'membership.emailVerified': true,
    });

    final prefs = SharedPreferences.getInstance();

    return prefs.then((value) {
      final state = MembershipState.fromCache(value);
      expect(state.deviceLimitReached, isFalse);
      expect(state.activeDeviceCount, 0);
      expect(state.canUnlockRadioDirectory, isTrue);
    });
  });

  test('MembershipState.fromCache denies access when the device limit is reached',
      () {
    SharedPreferences.setMockInitialValues({
      'membership.email': 'buyer@example.com',
      'membership.hasLifetimeAccess': true,
      'membership.emailVerified': true,
      'membership.deviceLimitReached': true,
      'membership.activeDeviceCount': 3,
    });

    final prefs = SharedPreferences.getInstance();

    return prefs.then((value) {
      final state = MembershipState.fromCache(value);
      expect(state.hasLifetimeAccess, isTrue);
      expect(state.deviceLimitReached, isTrue);
      expect(state.hasAccess, isFalse);
      expect(state.canUnlockRadioDirectory, isFalse);
    });
  });
}
