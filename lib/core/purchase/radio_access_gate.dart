/// FILE: lib/core/purchase/radio_access_gate.dart
import 'package:flutter/material.dart';

import '../membership/membership_service.dart';
import 'email_verify_dialog.dart';
import 'pending_purchase_action.dart';

/// Gates access to the World Radio Explorer module behind a one-time
/// Lifetime Access purchase. Every other OmniToolkit module remains free
/// and is never blocked by this gate.
class RadioAccessGate {
  static Future<bool> hasAccess() async {
    final state = await MembershipService().cached();
    return state?.hasLifetimeAccess ?? false;
  }

  /// Checks cached entitlement and either invokes [onGranted] immediately or
  /// shows the upgrade dialog explaining Lifetime Access.
  static Future<void> ensureAccess(
    BuildContext context,
    VoidCallback onGranted,
  ) async {
    if (await hasAccess()) {
      onGranted();
      return;
    }
    if (!context.mounted) return;
    _showUpgradeDialog(context, onGranted);
  }

  static void _showUpgradeDialog(BuildContext context, VoidCallback onGranted) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Unlock World Radio Explorer'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'World Radio Explorer is a premium feature. All other '
              'OmniToolkit modules remain free forever.',
            ),
            SizedBox(height: 16),
            Text('Special Launch Pricing',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('OmniToolkit Lifetime Access'),
            Text(r'$9.99 USD (Launch Price)'),
            SizedBox(height: 4),
            Text(
              'Available for the first 500 customers. Pricing may increase '
              'afterward.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Not Now'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              RestorePurchaseFlow.run(context);
            },
            child: const Text('Restore Purchase'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _unlockNow(context);
            },
            child: const Text('Unlock Now'),
          ),
        ],
      ),
    );
  }

  static Future<void> _unlockNow(BuildContext context) async {
    final verifiedUser = MembershipService().verifiedUser;
    if (verifiedUser != null) {
      Navigator.of(context).pushNamed('/billing-notice');
      return;
    }
    await EmailVerifyDialog.requestVerification(
      context,
      PendingPurchaseAction.unlock,
    );
  }
}

/// Restores a prior Lifetime Access purchase for the current (or newly
/// verified) email address.
class RestorePurchaseFlow {
  static Future<void> run(BuildContext context) async {
    final service = MembershipService();
    final verifiedUser = service.verifiedUser;
    if (verifiedUser == null) {
      await EmailVerifyDialog.requestVerification(
        context,
        PendingPurchaseAction.restore,
      );
      return;
    }
    try {
      final state = await service.startOrRestore();
      if (!context.mounted) return;
      if (state.hasLifetimeAccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Lifetime Membership Activated. World Radio Explorer is unlocked.',
          ),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No purchase was found for this email.'),
        ));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'We could not check your membership right now. Please try again.',
          ),
        ));
      }
    }
  }
}