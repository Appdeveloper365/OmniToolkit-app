/// FILE: lib/core/purchase/purchase_verification_dialog.dart
import 'package:flutter/material.dart';

import '../membership/membership_service.dart';
import 'email_verify_dialog.dart';
import 'pending_purchase_action.dart';
import 'radio_launch_controller.dart';

/// Primary "Restore Purchase" entry point.
///
/// Verify Purchase checks Firestore (via a public, no-auth-required Cloud
/// Function) immediately -- Firebase email-link verification is never
/// required just to find out whether an email already owns Lifetime
/// Access. Everything happens inline in this one dialog:
///   * Lifetime Membership found -> activate immediately, no further steps.
///   * Not found -> offer to continue with payment (which still verifies
///     email ownership before Stripe checkout, same as before).
/// "Send Verification Link" remains available as a secondary action for
/// anyone who wants to skip straight to checkout.
class PurchaseVerificationDialog {
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => _PurchaseVerificationDialogBody(rootContext: context),
    );
  }
}

class _PurchaseVerificationDialogBody extends StatefulWidget {
  const _PurchaseVerificationDialogBody({required this.rootContext});

  final BuildContext rootContext;

  @override
  State<_PurchaseVerificationDialogBody> createState() =>
      _PurchaseVerificationDialogBodyState();
}

class _PurchaseVerificationDialogBodyState
    extends State<_PurchaseVerificationDialogBody> {
  final _emailController = TextEditingController();
  bool _checking = false;
  bool _checked = false;
  bool _hasLifetimeAccess = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _verifyPurchase() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _error = 'Enter the email address used during checkout.';
        _checked = false;
      });
      return;
    }
    setState(() {
      _checking = true;
      _error = null;
      _checked = false;
    });
    try {
      final state = await MembershipService().lookupEntitlementByEmail(email);
      if (!mounted) return;
      setState(() {
        _checking = false;
        _checked = true;
        _hasLifetimeAccess = state.hasLifetimeAccess;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _error =
            'We could not check membership status right now. Please try again.';
      });
    }
  }

  void _activateNow() {
    Navigator.of(context).pop();
    final root = widget.rootContext;
    if (root.mounted) {
      ScaffoldMessenger.of(root).showSnackBar(const SnackBar(
        content: Text(
          'Lifetime Membership Activated. World Radio Explorer is unlocked.',
        ),
      ));
      RadioLaunchController.requestOpen();
    }
  }

  void _continueWithPayment() {
    Navigator.of(context).pop();
    final root = widget.rootContext;
    if (root.mounted) {
      final verifiedUser = MembershipService().verifiedUser;
      if (verifiedUser != null) {
        Navigator.of(root).pushNamed('/billing-notice');
      } else {
        EmailVerifyDialog.requestVerification(root, PendingPurchaseAction.unlock);
      }
    }
  }

  void _sendVerificationLinkInstead() {
    Navigator.of(context).pop();
    final root = widget.rootContext;
    if (root.mounted) {
      EmailVerifyDialog.requestVerification(
          root, PendingPurchaseAction.restore);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Verify Purchase'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the email address used at checkout. We will check for '
              'an existing Lifetime Membership right away -- no email '
              'verification required for this check.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                labelText: 'Purchase email',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _verifyPurchase(),
            ),
            const SizedBox(height: 16),
            if (_checking) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ] else if (_checked && _hasLifetimeAccess) ...[
              const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lifetime Membership Found',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'This email already owns Lifetime Access to World Radio '
                'Explorer.',
              ),
            ] else if (_checked && !_hasLifetimeAccess) ...[
              const Row(
                children: [
                  Icon(Icons.info_outline_rounded),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No Lifetime Membership was found for this email yet.',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _sendVerificationLinkInstead,
          child: const Text('Send Verification Link'),
        ),
        if (_checked && _hasLifetimeAccess)
          FilledButton(
            onPressed: _activateNow,
            child: const Text('Activate Lifetime Membership'),
          )
        else if (_checked && !_hasLifetimeAccess)
          FilledButton(
            onPressed: _continueWithPayment,
            child: const Text('Continue With Payment'),
          )
        else
          FilledButton(
            onPressed: _checking ? null : _verifyPurchase,
            child: const Text('Verify Purchase'),
          ),
      ],
    );
  }
}