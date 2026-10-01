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
  static Future<DeviceIdentity>? _currentRequest;

  Future<DeviceIdentity> current() {
    final inFlight = _currentRequest;
    if (inFlight != null) {
      return inFlight;
    }
    final request = _loadCurrent();
    _currentRequest = request;
    request.whenComplete(() {
      if (identical(_currentRequest, request)) {
        _currentRequest = null;
      }
    });
    return request;
  }

  Future<DeviceIdentity> _loadCurrent() async {
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

  /// Generate a cryptographically secure device ID with high entropy
  /// Uses platform secure random (Random.secure()) with expanded alphabet
  /// to provide ~128 bits of entropy (24 chars from 64-char alphabet)
  String _generateDeviceId() {
    // Use URL-safe base64 alphabet for compact representation
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
    final random = Random.secure();
    final codeUnits = List<int>.generate(
      24,
      (_) => alphabet.codeUnitAt(random.nextInt(alphabet.length)),
    );
    return String.fromCharCodes(codeUnits);
  }
}