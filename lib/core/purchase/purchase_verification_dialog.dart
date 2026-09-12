/// FILE: lib/core/purchase/purchase_verification_dialog.dart
import 'dart:async';
import 'package:flutter/material.dart';

import '../membership/membership_service.dart';
import '../navigation/main_navigation.dart';
import 'email_verify_dialog.dart';
import 'pending_purchase_action.dart';
import 'staged_loader.dart';

enum _RestoreState { input, checking, verified, notFound, error }

/// Primary "Restore Purchase" entry point.
///
/// Verify Purchase checks Firestore + Stripe Search API immediately --
/// Firebase email-link verification is never required just to find out
/// whether an email already owns Lifetime Access. Everything happens inline
/// in this one dialog:
///   * Lifetime Membership found -> staged loader -> verified (auto-open in 1s)
///   * Not found -> offer to continue with payment or try another email
///   * Send Verification Link remains available as a secondary action.
class PurchaseVerificationDialog {
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
  _RestoreState _state = _RestoreState.input;
  String _checkedEmail = '';
  String _error = '';
  Timer? _autoRedirectTimer;

  bool get _emailValid => _emailController.text.trim().contains('@');

  @override
  void dispose() {
    _autoRedirectTimer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _verifyPurchase() async {
    final email = _emailController.text.trim().toLowerCase();
    if (!email.contains('@')) {
      setState(() {
        _error = 'Enter the email address used during checkout.';
        _state = _RestoreState.error;
      });
      return;
    }

    setState(() {
      _checkedEmail = email;
      _state = _RestoreState.checking;
    });

    try {
      final state = await MembershipService().lookupEntitlementByEmail(email);
      if (!mounted) return;
      if (state.hasLifetimeAccess) {
        setState(() => _state = _RestoreState.verified);
        _autoRedirectTimer?.cancel();
        _autoRedirectTimer = Timer(const Duration(seconds: 1), () {
          if (!mounted) return;
          _openRadioDirectory();
        });
      } else {
        setState(() => _state = _RestoreState.notFound);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = "Couldn't reach the server. Please try again.";
        _state = _RestoreState.error;
      });
    }
  }

  void _openRadioDirectory() {
    _autoRedirectTimer?.cancel();
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
    final root = widget.rootContext;
    if (root.mounted) {
      Navigator.of(root).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainNavigation(initialIndex: 2),
        ),
        (route) => false,
      );
      ScaffoldMessenger.of(root).showSnackBar(const SnackBar(
        content: Text(
          'Lifetime Membership Activated. World Radio Explorer is unlocked.',
        ),
      ));
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
        EmailVerifyDialog.requestVerification(
          root,
          PendingPurchaseAction.unlock,
          prefill: _checkedEmail,
        );
      }
    }
  }

  void _sendVerificationLinkInstead() {
    Navigator.of(context).pop();
    final root = widget.rootContext;
    if (root.mounted) {
      EmailVerifyDialog.requestVerification(
        root,
        PendingPurchaseAction.restore,
        prefill: _emailController.text.trim(),
      );
    }
  }

  String _title() {
    switch (_state) {
      case _RestoreState.verified:
        return '✅ Lifetime Membership Verified';
      case _RestoreState.notFound:
        return 'No Membership Found';
      case _RestoreState.error:
        return 'Something went wrong';
      case _RestoreState.checking:
        return 'Checking Membership...';
      case _RestoreState.input:
        return 'Restore Purchase';
    }
  }

  Widget _content() {
    switch (_state) {
      case _RestoreState.input:
        return Column(
          key: const ValueKey('input'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the email you purchased with, then tap Verify Purchase '
              'to restore your Lifetime Access.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _emailValid ? _verifyPurchase() : null,
              decoration: const InputDecoration(
                hintText: 'you@example.com',
                labelText: 'Purchase email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );

      case _RestoreState.checking:
        return const StagedLoader(key: ValueKey('checking'));

      case _RestoreState.verified:
        return const Column(
          key: ValueKey('verified'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.verified_rounded, color: Colors.green, size: 56),
            SizedBox(height: 16),
            Text(
              'This email already owns Lifetime Access.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            SizedBox(height: 8),
            Text(
              'World Radio Explorer has been unlocked.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Opening World Radio Explorer...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(),
          ],
        );

      case _RestoreState.notFound:
        return const Column(
          key: ValueKey('notfound'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('❌ No Lifetime Membership found.'),
            SizedBox(height: 12),
            Text('World Radio Explorer requires Lifetime Access.'),
            SizedBox(height: 12),
            Text(
              r'$9.99 USD (Launch Price)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('Available for the first 500 customers.'),
          ],
        );

      case _RestoreState.error:
        return Text(
          _error,
          key: const ValueKey('error'),
          style: const TextStyle(color: Colors.red),
        );
    }
  }

  List<Widget> _actions() {
    switch (_state) {
      case _RestoreState.input:
        return [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _sendVerificationLinkInstead,
            child: const Text('Send Verification Link'),
          ),
          FilledButton(
            onPressed: _emailValid ? _verifyPurchase : null,
            child: const Text('Verify Purchase'),
          ),
        ];

      case _RestoreState.checking:
        return const [];

      case _RestoreState.verified:
        return [
          FilledButton(
            onPressed: _openRadioDirectory,
            child: const Text('Open Radio Directory'),
          ),
          OutlinedButton(
            onPressed: _openRadioDirectory,
            child: const Text('Return To Radio Directory'),
          ),
        ];

      case _RestoreState.notFound:
        return [
          TextButton(
            onPressed: () => setState(() => _state = _RestoreState.input),
            child: const Text('Try Another Email'),
          ),
          FilledButton(
            onPressed: _continueWithPayment,
            child: const Text('Continue With Payment'),
          ),
        ];

      case _RestoreState.error:
        return [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () => setState(() => _state = _RestoreState.input),
            child: const Text('Try Again'),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_title()),
      content: AnimatedSize(
        duration: const Duration(milliseconds: 150),
        child: SingleChildScrollView(
          child: _content(),
        ),
      ),
      actions: _actions(),
    );
  }
}