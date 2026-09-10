import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Billing Notice: shown before Stripe Checkout. Anonymous visitors may
/// purchase Lifetime Membership without signing in. If the visitor happens
/// to be signed in, their account email is sent as a checkout hint so it is
/// linked immediately; otherwise Stripe Checkout collects the purchaser's
/// email directly and the purchase is later matched by email at sign-in.
class BillingNoticeScreen extends StatefulWidget {
  const BillingNoticeScreen({super.key});

  static const purchaseNoticeItems = [
    'Lifetime Access is linked to the email address used during checkout.',
    'Please use an email address that you intend to keep.',
    'Email changes after purchase are not currently supported.',
    'Access cannot be transferred to another account.',
    'All sales are final and non-refundable.',
  ];

  @override
  State<BillingNoticeScreen> createState() => _BillingNoticeScreenState();
}

class _BillingNoticeScreenState extends State<BillingNoticeScreen> {
  bool _disclaimerAccepted = false;
  bool _isStartingCheckout = false;

  Future<void> _startCheckout() async {
    if (_isStartingCheckout || !_disclaimerAccepted) return;
    setState(() => _isStartingCheckout = true);
    try {
      final signedInEmail =
          FirebaseAuth.instance.currentUser?.email?.trim().toLowerCase();

      final callable = FirebaseFunctions.instance.httpsCallable(
        'createStripeCheckoutSession',
      );
      final result = await callable.call<Map<String, dynamic>>({
        'disclaimerAccepted': true,
        if (signedInEmail != null && signedInEmail.isNotEmpty)
          'billingEmail': signedInEmail,
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
      if (mounted) {
        _showError(_friendlyMessage(error));
      }
    } catch (error) {
      if (mounted) {
        _showError(
          'Checkout could not be started. Please try again in a moment. '
          '($error)',
        );
      }
    } finally {
      if (mounted) setState(() => _isStartingCheckout = false);
    }
  }

  String _friendlyMessage(FirebaseFunctionsException error) {
    switch (error.code) {
      case 'not-found':
        return 'Checkout is not available yet. Please try again later or '
            'contact support.';
      case 'failed-precondition':
        return error.message ??
            'Please accept the disclaimer before continuing.';
      case 'unauthenticated':
        return error.message ?? 'Please sign in and try again.';
      case 'invalid-argument':
        return error.message ??
            'The billing email does not match your account.';
      default:
        return error.message ??
            'Checkout could not be started. Please try again.';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
                      'Before You Purchase',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: BillingNoticeScreen.purchaseNoticeItems
                          .map((item) => _NoticeBullet(item))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _disclaimerAccepted,
                      onChanged: (value) =>
                          setState(() => _disclaimerAccepted = value ?? false),
                      title: const Text(
                        'I understand access is linked to my purchase email.',
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: (_isStartingCheckout || !_disclaimerAccepted)
                          ? null
                          : _startCheckout,
                      child: Text(
                          _isStartingCheckout ? 'Opening checkout...' : 'Next'),
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

class _NoticeBullet extends StatelessWidget {
  const _NoticeBullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
