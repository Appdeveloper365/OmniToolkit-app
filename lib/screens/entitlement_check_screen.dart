import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/membership/membership_service.dart';
import '../core/navigation/main_navigation.dart';
import '../core/purchase/email_verify_dialog.dart';
import '../core/purchase/entitlement_watcher.dart';
import '../core/purchase/pending_purchase_action.dart';
import '../core/purchase/radio_access_gate.dart';
import '../core/purchase/staged_loader.dart';

/// Settings > Membership Status.
///
/// Verify Purchase is the primary action and checks Firestore immediately --
/// no Firebase email-link verification is required just to find out whether
/// an email already owns Lifetime Access. Signed-in (verified) users are
/// checked automatically against their account email; anonymous visitors
/// enter the email used at Stripe Checkout. Everything resolves within this
/// one screen: Lifetime Membership Found -> Activate, or Continue With
/// Payment.
///
/// If no purchase is found, a verification link is sent automatically (no
/// extra button tap, no re-entering the email in a second dialog) so the
/// user only has to check their inbox. Clicking that link opens OmniToolkit
/// and lands directly on the payment screen (see
/// MainNavigation._completePendingVerification, PendingPurchaseAction.unlock)
/// instead of asking them to confirm anything else first.
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
  bool _deviceLimitReached = false;
  String? _error;
  String? _lastCheckedEmail;
  bool _verificationLinkSent = false;
  bool _isSendingLink = false;

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
        _deviceLimitReached = state.deviceLimitReached;
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
      final normalized = email.trim().toLowerCase();
      setState(() {
        _lastCheckedEmail = normalized;
        _hasLifetimeAccess = state.hasLifetimeAccess;
        _deviceLimitReached = state.deviceLimitReached;
        _checked = true;
        _isChecking = false;
      });
      if (!state.hasLifetimeAccess) {
        // No purchase found for an unverified email: automatically send the
        // verification link (no extra button tap, no re-entering the email
        // in a second dialog). Clicking the link in that email will land
        // the user directly on the payment screen.
        _autoSendVerificationLink(normalized);
      }
    } catch (_) {
      setState(() {
        _error =
            'We could not check membership status right now. Please try again.';
        _isChecking = false;
      });
    }
  }

  void _openRadioDirectory() {
    RadioAccessGate.ensureAccess(context, () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainNavigation(initialIndex: 2),
        ),
        (route) => false,
      );
    });
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

  /// Sends a Firebase email-link verification message for [email] without
  /// opening a second dialog or asking the user to re-type/re-confirm an
  /// email we already have. Marks the pending action as `unlock` so that
  /// once the user clicks the link, MainNavigation routes them straight to
  /// the payment screen instead of showing another confirmation dialog.
  Future<void> _autoSendVerificationLink(String email, {bool resend = false}) async {
    if (email.isEmpty) return;
    if (_isSendingLink) return;
    if (_verificationLinkSent && !resend) return;
    setState(() => _isSendingLink = true);
    try {
      await PendingPurchaseActionStore.set(PendingPurchaseAction.unlock);
      await MembershipService().sendVerificationLink(email);
      EntitlementWatcher.instance.watch(email);
      if (!mounted) return;
      setState(() {
        _verificationLinkSent = true;
        _isSendingLink = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Verification link sent to $email. Open the email and click the '
          'link -- it will take you straight to payment.',
        ),
        duration: const Duration(seconds: 5),
      ));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSendingLink = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Could not send the verification link. Please try again.',
        ),
      ));
    }
  }

  void _resendVerificationLink() {
    final email = _lastCheckedEmail ?? _purchaseEmailController.text.trim().toLowerCase();
    _autoSendVerificationLink(email, resend: true);
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
                          if (userEmail.isEmpty && !_hasLifetimeAccess) ...[
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
                            const Icon(Icons.verified_rounded,
                                color: Colors.green, size: 64),
                            const SizedBox(height: 16),
                            Text(
                              '✅ Lifetime Membership Verified',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              email.isNotEmpty
                                  ? 'This email ($email) already owns Lifetime Access.'
                                  : 'This email already owns Lifetime Access.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Lifetime access is verified.',
                              textAlign: TextAlign.center,
                            ),
                            if (_deviceLimitReached) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'Device Limit Reached\nThis membership is active on the maximum number of devices.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ] else ...[
                              if (userEmail.isEmpty) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'Please verify this email to activate Radio Directory on this device.',
                                  textAlign: TextAlign.center,
                                ),
                              ] else ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'World Radio Explorer has been unlocked.',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
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
                            if (userEmail.isEmpty && _verificationLinkSent) ...[
                              const SizedBox(height: 16),
                              Text(
                                '✅ Verification link sent to $email. Open '
                                'the email and click the link -- it will '
                                'take you straight to payment, with no need '
                                'to re-enter your email.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                          const SizedBox(height: 20),
                          if (_hasLifetimeAccess) ...[
                            if (userEmail.isEmpty) ...[
                              FilledButton.icon(
                                icon: const Icon(Icons.mark_email_read_outlined),
                                onPressed: _isSendingLink
                                    ? null
                                    : () => _autoSendVerificationLink(
                                        _lastCheckedEmail ??
                                            _purchaseEmailController.text
                                                .trim()
                                                .toLowerCase(),
                                        resend: _verificationLinkSent,
                                      ),
                                label: Text(
                                  _isSendingLink
                                      ? 'Sending...'
                                      : (_verificationLinkSent
                                          ? 'Resend Verification Link'
                                          : 'Send Verification Link'),
                                ),
                              ),
                            ] else if (_deviceLimitReached) ...[
                              FilledButton.icon(
                                icon:
                                    const Icon(Icons.workspace_premium_rounded),
                                onPressed: () => Navigator.pushNamed(
                                    context, '/premium-membership'),
                                label: const Text('Manage Active Devices'),
                              ),
                            ] else ...[
                              FilledButton.icon(
                                icon: const Icon(Icons.radio),
                                onPressed: _openRadioDirectory,
                                label: const Text('Open Radio Directory'),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: _openRadioDirectory,
                                child: const Text('Return To Radio Directory'),
                              ),
                            ],
                          ] else if (_checked && userEmail.isEmpty) ...[
                            // Verification link was already sent automatically
                            // as soon as "not found" was determined -- no
                            // extra button tap and no second dialog asking
                            // the user to re-enter/re-confirm their email.
                            FilledButton.icon(
                              icon: const Icon(Icons.mark_email_read_outlined),
                              onPressed: _isSendingLink ? null : _resendVerificationLink,
                              label: Text(
                                _isSendingLink
                                    ? 'Sending...'
                                    : (_verificationLinkSent
                                        ? 'Resend Verification Link'
                                        : 'Send Verification Link'),
                              ),
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
                          if (_checked && !_hasLifetimeAccess) ...[
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