import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BillingNoticeScreen extends StatefulWidget {
  const BillingNoticeScreen({super.key});

  static const billingEmailNotice =
      'Important: Please use the same email address for your account and your purchase. '
      'Access is linked to the billing email used during checkout. Email changes are not '
      'currently supported after purchase.';

  @override
  State<BillingNoticeScreen> createState() => _BillingNoticeScreenState();
}

class _BillingNoticeScreenState extends State<BillingNoticeScreen> {
  bool _isStartingCheckout = false;

  Future<void> _startCheckout() async {
    if (_isStartingCheckout) return;
    setState(() => _isStartingCheckout = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email?.trim().toLowerCase();
      if (user == null || email == null || email.isEmpty) {
        throw FirebaseFunctionsException(
          code: 'unauthenticated',
          message: 'An authenticated account with an email address is required before checkout.',
        );
      }

      final callable = FirebaseFunctions.instance.httpsCallable(
        'createStripeCheckoutSession',
      );
      final result = await callable.call<Map<String, dynamic>>({
        'billingEmail': email,
      });
      final sessionUrl = result.data['sessionUrl'] as String?;
      if (sessionUrl == null || sessionUrl.isEmpty) {
        throw FirebaseFunctionsException(
          code: 'internal',
          message: 'Stripe checkout URL was not returned.',
        );
      }

      final checkoutUri = Uri.parse(sessionUrl);
      if (!await launchUrl(checkoutUri, mode: LaunchMode.externalApplication)) {
        throw FirebaseFunctionsException(
          code: 'unavailable',
          message: 'Stripe Checkout could not be opened.',
        );
      }
    } on FirebaseFunctionsException catch (error) {
      if (mounted) _showError(error.message ?? 'Checkout could not be started.');
    } finally {
      if (mounted) setState(() => _isStartingCheckout = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Billing Notice')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.receipt_long_rounded, size: 56),
                    const SizedBox(height: 20),
                    Text(
                      'Before checkout',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      BillingNoticeScreen.billingEmailNotice,
                      textAlign: TextAlign.center,
                      style: TextStyle(height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isStartingCheckout ? null : _startCheckout,
                      child: Text(_isStartingCheckout ? 'Opening checkout...' : 'Next'),
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