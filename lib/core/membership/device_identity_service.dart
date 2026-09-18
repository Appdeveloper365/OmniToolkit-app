import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdentity {
  const DeviceIdentity({
    required this.deviceId,
    required this.platform,
  });

  final String deviceId;
  final String platform;
}

class DeviceIdentityService {
  static const _deviceIdKey = 'membership.deviceId';

  Future<DeviceIdentity> current() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString(_deviceIdKey)?.trim() ?? '';
    if (deviceId.isEmpty) {
      deviceId = _generateDeviceId();
      await prefs.setString(_deviceIdKey, deviceId);
    }
    return DeviceIdentity(
      deviceId: deviceId,
      platform: _platformName(),
    );
  }

  String _platformName() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  String _generateDeviceId() {
    const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    final codeUnits = List<int>.generate(
      24,
      (_) => alphabet.codeUnitAt(random.nextInt(alphabet.length)),
    );
    return String.fromCharCodes(codeUnits);
  }
}
