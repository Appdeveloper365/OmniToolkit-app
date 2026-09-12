/// FILE: lib/core/purchase/radio_launch_controller.dart
import 'package:flutter/foundation.dart';

/// Lets EntitlementWatcher tell the currently-mounted MainNavigation to jump
/// straight to the Radio Explorer tab the instant Lifetime Access is
/// granted, without needing a BuildContext that may have been popped or
/// disposed by the time the purchase completes.
class RadioLaunchController {
  RadioLaunchController._();

  static VoidCallback? _onGranted;

  static void register(VoidCallback callback) => _onGranted = callback;

  static void unregister(VoidCallback callback) {
    if (_onGranted == callback) _onGranted = null;
  }

  static void requestOpen() => _onGranted?.call();
}