import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/membership/membership_service.dart';
import '../core/navigation/main_navigation.dart';
import '../core/purchase/email_verify_dialog.dart';
import '../core/purchase/pending_purchase_action.dart';
import '../core/purchase/staged_loader.dart';

/// Settings > Membership Status.
///
/// Verify Purchase is the primary action and checks Firestore immediately --
/// no Firebase email-link verification is required just to find out whether
/// an email already owns Lifetime Access. Signed-in (verified) users are
/// checked automatically against their account email; anonymous visitors
/// enter the email used at Stripe Checkout. Everything resolves within this
/// one screen: Lifetime Membership Found -> Activate, or Continue With
/// Payment. Send Verification Link remains available as a secondary option.
class EntitlementCheckScreen extends StatefulWidget {
  const EntitlementCheckScreen({super.key});

  @override
  State<EntitlementCheckScreen> createState() => _EntitlementCheckScreenState();
}

class _EntitlementCheckScreenState extends State<EntitlementCheckScreen> {
  final _purchaseEmailController = TextEditingController();
  bool _isChecking = true;
  bool _checked = false;
  bool _hasLifetimeAccess = false;
  String? _error;
  String? _lastCheckedEmail;

  @override
  void initState() {
    super.initState();
    _autoCheckSignedInUser();
  }

  @override
  void dispose() {
    _purchaseEmailController.dispose();
    super.dispose();
  }

  /// On open: if a verified account is already signed in, check its
  /// entitlement automatically. Otherwise show the Verify Purchase form
  /// immediately -- no verification required to reach it.
  Future<void> _autoCheckSignedInUser() async {
    final accountEmail =
        FirebaseAuth.instance.currentUser?.email?.trim().toLowerCase() ?? '';
    if (accountEmail.isEmpty) {
      setState(() => _isChecking = false);
      return;
    }
    setState(() => _isChecking = true);
    try {
      final state = await MembershipService().startOrRestore();
      setState(() {
        _lastCheckedEmail = accountEmail;
        _hasLifetimeAccess = state.hasLifetimeAccess;
        _checked = true;
        _isChecking = false;
      });
    } catch (_) {
      setState(() => _isChecking = false);
    }
  }

  Future<void> _verifyPurchase() async {
    final email = _purchaseEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _error = 'Enter the email address used during checkout.';
        _checked = false;
      });
      return;
    }
    setState(() {
      _isChecking = true;
      _error = null;
      _checked = false;
    });
    try {
      final state = await MembershipService().lookupEntitlementByEmail(email);
      setState(() {
        _lastCheckedEmail = email.trim().toLowerCase();
        _hasLifetimeAccess = state.hasLifetimeAccess;
        _checked = true;
        _isChecking = false;
      });
    } catch (_) {
      setState(() {
        _error =
            'We could not check membership status right now. Please try again.';
        _isChecking = false;
      });
    }
  }

  void _continueWithPayment() {
    final verifiedUser = MembershipService().verifiedUser;
    if (verifiedUser != null) {
      // Already verified: skip straight to checkout, same as RadioAccessGate.
      Navigator.of(context).pushNamed('/billing-notice');
      return;
    }
    EmailVerifyDialog.requestVerification(
      context,
      PendingPurchaseAction.unlock,
      prefill: _lastCheckedEmail ?? _purchaseEmailController.text.trim(),
    );
  }

  void _sendVerificationLinkInstead() {
    EmailVerifyDialog.requestVerification(
      context,
      PendingPurchaseAction.restore,
      prefill: _purchaseEmailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userEmail =
        FirebaseAuth.instance.currentUser?.email?.trim().toLowerCase() ?? '';
    final email = userEmail.isNotEmpty ? userEmail : (_lastCheckedEmail ?? '');

    return Scaffold(
      appBar: AppBar(title: const Text('Membership Status')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _isChecking
                    ? const StagedLoader()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (userEmail.isEmpty) ...[
                            const Text(
                              'Enter the email address used during Stripe '
                              'checkout. We will check for an existing '
                              'Lifetime Membership right away -- no email '
                              'verification required for this check.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _purchaseEmailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                labelText: 'Purchase email',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _verifyPurchase(),
                            ),
                            const SizedBox(height: 20),
                          ],
                          if (_error != null) ...[
                            Text(_error!, textAlign: TextAlign.center),
                          ] else if (_hasLifetimeAccess) ...[
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.green, size: 56),
                            const SizedBox(height: 16),
                            Text(
                              'Lifetime Membership Found\nActive for $email.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ] else if (_checked) ...[
                            const Icon(Icons.info_outline_rounded, size: 56),
                            const SizedBox(height: 16),
                            Text(
                              'No Lifetime Membership was found for '
                              '${email.isEmpty ? 'that email' : email}. '
                              'Access is linked to the billing email used at '
                              'checkout.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                          const SizedBox(height: 20),
                          if (_hasLifetimeAccess) ...[
                            FilledButton(
                              onPressed: () => Navigator.of(context)
                                  .pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const MainNavigation(initialIndex: 2),
                                ),
                                (route) => false,
                              ),
                              child: const Text(
                                  'Continue to World Radio Explorer'),
                            ),
                          ] else if (_checked && userEmail.isEmpty) ...[
                            FilledButton(
                              onPressed: _continueWithPayment,
                              child: const Text('Continue With Payment'),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _sendVerificationLinkInstead,
                              child: const Text('Send Verification Link'),
                            ),
                          ] else if (_checked && userEmail.isNotEmpty) ...[
                            FilledButton(
                              onPressed: _continueWithPayment,
                              child: const Text('Continue With Payment'),
                            ),
                          ] else ...[
                            FilledButton(
                              onPressed: userEmail.isEmpty
                                  ? _verifyPurchase
                                  : _autoCheckSignedInUser,
                              child: const Text('Verify Purchase'),
                            ),
                          ],
                          if (_checked) ...[
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: userEmail.isEmpty
                                  ? _verifyPurchase
                                  : _autoCheckSignedInUser,
                              child: const Text('Check Again'),
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}