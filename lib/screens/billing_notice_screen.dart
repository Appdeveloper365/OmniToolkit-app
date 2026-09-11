import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Billing Notice: shown before Stripe Checkout. Checkout is available only
/// after the visitor acknowledges the purchase terms.
class BillingNoticeScreen extends StatefulWidget {
  const BillingNoticeScreen({super.key});

  static const purchaseNoticeItems = [
    'Lifetime Access is linked to the verified email address used during checkout.',
    'Please use an email address that you intend to keep.',
    'Email changes are not currently supported.',
    'Access cannot be transferred to another account.',
    'Notes are stored locally on your device and are not backed up to the cloud.',
    'Deleting the app or clearing app data may permanently remove local notes.',
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
          'Checkout could not be started. Please try again in a moment.',
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
        return 'Please acknowledge the purchase information before continuing.';
      case 'unauthenticated':
        return 'Verify your email before continuing.';
      case 'invalid-argument':
        return 'The billing email must match your verified account email.';
      default:
        return 'Checkout could not be started. Please try again.';
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
                      'Special Launch Pricing',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'OmniToolkit Lifetime Access',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      r'$9.99 USD (Launch Price)',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Available for the first 500 customers.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pricing may increase after the first 500 purchases.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Before You Purchase',
                      style: Theme.of(context).textTheme.titleLarge,
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
                        'I acknowledge and agree to the information above.',
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
