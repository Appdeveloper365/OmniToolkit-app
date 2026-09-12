/// FILE: lib/core/purchase/entitlement_watcher.dart
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../membership/membership_service.dart';
import 'pending_purchase_action.dart';
import 'radio_launch_controller.dart';

/// Polls entitlement status via secure callable functions so the app
/// auto-unlocks soon after the Stripe webhook marks a purchase complete --
/// without the user needing to reopen the app or tap "Restore Purchase" again.
///
/// Firestore itself is server-side only: entitlements/{email} is never
/// read directly by the client (see firestore.rules). All status checks go
/// through MembershipService callable functions.
class EntitlementWatcher {
  EntitlementWatcher._();
  static final EntitlementWatcher instance = EntitlementWatcher._();

  static const _pollInterval = Duration(seconds: 5);
  static const _maxAttempts = 60; // ~5 minutes

  Timer? _timer;
  String? _watchedEmail;
  int _attempts = 0;

  bool get isWatching => _timer != null;
  String? get watchedEmail => _watchedEmail;

  void watch(String email, {VoidCallback? onUnlocked}) {
    final normalized = email.trim().toLowerCase();
    if (_watchedEmail == normalized && _timer != null) return;
    stop();
    _watchedEmail = normalized;
    _attempts = 0;
    _timer = Timer.periodic(_pollInterval, (_) => _poll(onUnlocked));
  }

  Future<void> _poll(VoidCallback? onUnlocked) async {
    final email = _watchedEmail;
    if (email == null) return;
    _attempts++;
    if (_attempts > _maxAttempts) {
      stop();
      return;
    }
    try {
      final service = MembershipService();
      bool owns = false;
      if (service.verifiedUser != null) {
        final state = await service.startOrRestore();
        owns = state.hasLifetimeAccess;
      } else {
        final state = await service.lookupEntitlementByEmail(email);
        owns = state.hasLifetimeAccess;
      }
      if (owns) {
        await PendingPurchaseActionStore.consume();
        stop();
        onUnlocked?.call();
        RadioLaunchController.requestOpen();
      }
    } catch (error) {
      debugPrint('[EntitlementWatcher] poll failed: $error');
      // Keep polling; the next successful attempt will pick up the purchase.
    }
  }

  /// Manual "I've paid -- Check Now" fallback: checks once, immediately.
  Future<bool> checkNow({String? emailOverride}) async {
    final email = emailOverride?.trim().toLowerCase() ?? _watchedEmail;
    if (email == null || email.isEmpty) return false;
    try {
      final service = MembershipService();
      bool owns = false;
      if (service.verifiedUser != null) {
        final state = await service.startOrRestore();
        owns = state.hasLifetimeAccess;
      } else {
        final state = await service.lookupEntitlementByEmail(email);
        owns = state.hasLifetimeAccess;
      }
      if (owns) {
        await PendingPurchaseActionStore.consume();
        stop();
        RadioLaunchController.requestOpen();
        return true;
      }
    } catch (_) {
      // Ignore; caller surfaces its own error message.
    }
    return false;
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _watchedEmail = null;
    _attempts = 0;
  }
}