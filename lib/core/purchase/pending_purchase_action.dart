/// FILE: lib/core/purchase/pending_purchase_action.dart
import 'package:shared_preferences/shared_preferences.dart';

/// The action the app should resume automatically once the user returns
/// through a clicked email verification link.
enum PendingPurchaseAction { unlock, restore }

/// Persists which purchase action to resume across the page reload that
/// happens when a user opens the app via the emailed verification link.
class PendingPurchaseActionStore {
  static const _key = 'purchase.pendingAction';

  static Future<void> set(PendingPurchaseAction action) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, action.name);
  }

  /// Reads and clears the pending action, if any.
  static Future<PendingPurchaseAction?> consume() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == null) return null;
    await prefs.remove(_key);
    for (final action in PendingPurchaseAction.values) {
      if (action.name == value) return action;
    }
    return null;
  }
}