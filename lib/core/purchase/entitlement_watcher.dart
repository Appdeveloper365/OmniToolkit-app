/// FILE: lib/core/purchase/entitlement_watcher.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../membership/membership_service.dart';
import 'pending_purchase_action.dart';
import 'radio_launch_controller.dart';

/// Watches entitlements/{email} in Firestore in real time so the app
/// auto-unlocks the instant the Stripe webhook marks a purchase complete --
/// the user never has to reopen the app or tap "Restore Purchase" again.
///
/// Requires firestore.rules to allow the verified owner to read their own
/// entitlement document directly (see firestore.rules).
class EntitlementWatcher {
  EntitlementWatcher._();
  static final EntitlementWatcher instance = EntitlementWatcher._();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;
  String? _watchedEmail;

  bool get isWatching => _sub != null;

  void watch(String email, {VoidCallback? onUnlocked}) {
    final normalized = email.trim().toLowerCase();
    if (_watchedEmail == normalized && _sub != null) return;
    _sub?.cancel();
    _watchedEmail = normalized;
    try {
      _sub = FirebaseFirestore.instance
          .collection('entitlements')
          .doc(normalized)
          .snapshots()
          .listen((snapshot) async {
        final data = snapshot.data();
        if (data == null || data['hasLifetimeAccess'] != true) return;
        await MembershipService().cacheLifetimeAccess(normalized);
        await PendingPurchaseActionStore.consume();
        await stop();
        onUnlocked?.call();
        RadioLaunchController.requestOpen();
      }, onError: (error) {
        debugPrint('[EntitlementWatcher] snapshot error: $error');
      });
    } catch (error) {
      debugPrint('[EntitlementWatcher] listen failed: $error');
    }
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    _watchedEmail = null;
  }
}