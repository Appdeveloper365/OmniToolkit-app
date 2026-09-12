import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/membership/membership_service.dart';
import '../core/navigation/main_navigation.dart';

/// Reconciles Lifetime Membership purchases by email. Signed-in users are
/// checked against their account email; anonymous visitors can enter the email
/// they used at Stripe Checkout.
class EntitlementCheckScreen extends StatefulWidget {
  const EntitlementCheckScreen({super.key});

  @override
  State<EntitlementCheckScreen> createState() => _EntitlementCheckScreenState();
}

class _EntitlementCheckScreenState extends State<EntitlementCheckScreen> {
  final _purchaseEmailController = TextEditingController();
  bool _isChecking = true;
  bool _hasLifetimeAccess = false;
  bool _matched = false;
  String? _error;
  String? _lastCheckedEmail;

  @override
  void initState() {
    super.initState();
    _checkEntitlement();
  }

  @override
  void dispose() {
    _purchaseEmailController.dispose();
    super.dispose();
  }

  Future<void> _checkEntitlement({bool requireEmail = false}) async {
    setState(() {
      _isChecking = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final accountEmail = user?.email?.trim().toLowerCase() ?? '';

      if (accountEmail.isNotEmpty) {
        // Route through MembershipService so the result is cached locally
        // (used by RadioAccessGate to unlock World Radio Explorer without
        // another Firestore round trip).
        final state = await MembershipService().startOrRestore();
        setState(() {
          _lastCheckedEmail = accountEmail;
          _hasLifetimeAccess = state.hasLifetimeAccess;
          _matched = true;
          _isChecking = false;
        });
        return;
      }

      final purchaseEmail = _purchaseEmailController.text.trim().toLowerCase();
      if (purchaseEmail.isEmpty) {
        setState(() {
          _isChecking = false;
          _matched = false;
          _hasLifetimeAccess = false;
          _error =
              requireEmail ? 'Enter the email used during checkout.' : null;
        });
        return;
      }

      final callable = FirebaseFunctions.instance.httpsCallable(
        'checkEntitlementByEmail',
      );
      final result = await callable.call<Map<String, dynamic>>({
        'email': purchaseEmail,
      });
      setState(() {
        _lastCheckedEmail = purchaseEmail;
        _hasLifetimeAccess = result.data['hasLifetimeAccess'] as bool? ?? false;
        _matched = result.data['matched'] as bool? ?? false;
        _isChecking = false;
      });
    } on FirebaseFunctionsException catch (_) {
      setState(() {
        _error =
            'We could not check membership status right now. Please try again.';
        _isChecking = false;
      });
    } on StateError catch (_) {
      setState(() {
        _error = 'Verify your email before checking membership status.';
        _isChecking = false;
      });
    }
  }

  void _checkEnteredPurchaseEmail() {
    _checkEntitlement(requireEmail: true);
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
                    ? const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Checking membership status...'),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (userEmail.isEmpty) ...[
                            const Text(
                              'Enter the email address used during Stripe checkout to restore your Lifetime Membership.',
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
                              onSubmitted: (_) => _checkEnteredPurchaseEmail(),
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
                              'Lifetime Membership is active for $email.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ] else if (_matched) ...[
                            const Icon(Icons.info_outline_rounded, size: 56),
                            const SizedBox(height: 16),
                            const Text(
                              'No active Lifetime Membership was found for this account.',
                              textAlign: TextAlign.center,
                            ),
                          ] else ...[
                            const Icon(Icons.mail_lock_outlined, size: 56),
                            const SizedBox(height: 16),
                            Text(
                              'We could not find a purchase for ${email.isEmpty ? 'that email' : email}. '
                              'Access is linked to the billing email used at checkout. '
                              'Please use the exact email address used during purchase.',
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
                            const SizedBox(height: 8),
                          ],
                          OutlinedButton(
                            onPressed: userEmail.isEmpty
                                ? _checkEnteredPurchaseEmail
                                : _checkEntitlement,
                            child: Text(userEmail.isEmpty
                                ? 'Check purchase email'
                                : 'Check again'),
                          ),
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
