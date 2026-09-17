import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/membership/membership_service.dart';
import '../core/navigation/main_navigation.dart';
import '../core/purchase/entitlement_watcher.dart';
import '../core/purchase/radio_access_gate.dart';
import '../core/purchase/radio_launch_controller.dart';

/// Billing Notice: shown before Stripe Checkout. Checkout is available only
/// after the visitor acknowledges the purchase terms.
///
/// EMAIL CONFIRMATION: Because Lifetime Access is permanently linked to the
/// purchase email and cannot be changed or transferred afterward, this
/// screen collects the billing email as two fields before opening Stripe:
/// 1. Email -- pre-filled automatically with the address the visitor just
///    verified (via the confirmation link or a prior sign-in), so nobody
///    has to type it in from scratch again.
/// 2. Confirm Email -- the visitor retypes the same address to confirm
///    there's no typo before money changes hands. [Continue With Payment]
///    stays disabled until both fields match.
/// Once confirmed, tapping continue opens the real Stripe Checkout page
/// directly (via `createStripeCheckoutSession` + external launch) -- no
/// extra screens or re-verification in between.
///
/// If the email is already entitled or createStripeCheckoutSession returns
/// { alreadyOwned: true }, this screen NEVER navigates to a blank page or
/// pops to an empty route. Instead, it presents the verified state with
/// "✅ Lifetime Membership Verified", automatic redirection to World Radio
/// Explorer, and an explicit [Open Radio Directory] fallback button.
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
  bool _alreadyOwned = false;
  String _verifiedEmail = '';
  Timer? _autoRedirectTimer;

  /// Pre-filled with the already-verified email (from the confirmation
  /// link or a prior sign-in). Locked (read-only) whenever we know that
  /// verified address, since Lifetime Access cannot be reassigned to a
  /// different email later.
  final _emailController = TextEditingController();

  /// Retyped by the visitor to confirm the pre-filled email above before
  /// payment starts -- a lightweight typo guard, since purchases are final
  /// and non-transferable.
  final _confirmEmailController = TextEditingController();
  bool _emailLocked = false;

  static final _emailPattern =
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailFieldsChanged);
    _confirmEmailController.addListener(_onEmailFieldsChanged);
    _checkInitialOwnership();
  }

  @override
  void dispose() {
    _autoRedirectTimer?.cancel();
    _emailController.dispose();
    _confirmEmailController.dispose();
    super.dispose();
  }

  void _onEmailFieldsChanged() {
    if (mounted) setState(() {});
  }

  String get _normalizedEmail => _emailController.text.trim().toLowerCase();

  String get _normalizedConfirmEmail =>
      _confirmEmailController.text.trim().toLowerCase();

  bool get _emailsProvided =>
      _normalizedEmail.isNotEmpty && _normalizedConfirmEmail.isNotEmpty;

  bool get _emailIsValid => _emailPattern.hasMatch(_normalizedEmail);

  bool get _emailsMatch =>
      _emailsProvided && _normalizedEmail == _normalizedConfirmEmail;

  /// Confirm-email error text, or null while there's nothing to warn about
  /// yet (fields empty, or already matching).
  String? get _confirmEmailError {
    if (_normalizedConfirmEmail.isEmpty) return null;
    if (!_emailIsValid) return null; // surfaced on the first field instead
    if (_normalizedConfirmEmail != _normalizedEmail) {
      return 'Emails do not match.';
    }
    return null;
  }

  bool get _canContinue =>
      _disclaimerAccepted &&
      _emailIsValid &&
      _emailsMatch &&
      !_isStartingCheckout;

  Future<void> _checkInitialOwnership() async {
    String signedInEmail = '';
    try {
      signedInEmail =
          FirebaseAuth.instance.currentUser?.email?.trim().toLowerCase() ?? '';
    } catch (_) {}

    if (signedInEmail.isNotEmpty && mounted) {
      // Pre-fill both fields with the already-verified email so the
      // visitor only has to retype (confirm) it, never type it from
      // scratch. Lock the primary field since Lifetime Access cannot be
      // reassigned to a different address later.
      setState(() {
        _emailController.text = signedInEmail;
        _emailLocked = true;
      });
    }

    try {
      final cached = await MembershipService().cached();
      if (cached?.hasLifetimeAccess == true) {
        if (!mounted) return;
        setState(() {
          _alreadyOwned = true;
          _verifiedEmail =
              signedInEmail.isNotEmpty ? signedInEmail : (cached?.email ?? '');
        });
        _scheduleAutoRedirect();
        return;
      }
      if (signedInEmail.isNotEmpty) {
        final state =
            await MembershipService().lookupEntitlementByEmail(signedInEmail);
        if (state.hasLifetimeAccess && mounted) {
          setState(() {
            _alreadyOwned = true;
            _verifiedEmail = signedInEmail;
          });
          _scheduleAutoRedirect();
        }
      }
    } catch (_) {
      // Continue normally to checkout form if offline
    }
  }

  void _scheduleAutoRedirect() {
    _autoRedirectTimer?.cancel();
    _autoRedirectTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        _openRadioDirectory(context);
      }
    });
  }

  void _openRadioDirectory(BuildContext context) {
    if (!mounted) return;
    RadioAccessGate.ensureAccess(context, () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainNavigation(initialIndex: 2),
        ),
        (route) => false,
      );
    });
  }

  Future<void> _startCheckout() async {
    if (_isStartingCheckout || !_canContinue) return;
    setState(() => _isStartingCheckout = true);
    try {
      // Use the visitor-confirmed email (pre-filled + retyped to match)
      // rather than silently re-reading Firebase Auth, so what they see on
      // screen is exactly what gets billed and unlocked.
      final billingEmail = _normalizedEmail;

      final callable = FirebaseFunctions.instance.httpsCallable(
        'createStripeCheckoutSession',
      );
      final result = await callable.call<Map<String, dynamic>>({
        'disclaimerAccepted': true,
        if (billingEmail.isNotEmpty) 'billingEmail': billingEmail,
      });

      // DUPLICATE PURCHASE PROTECTION (Server Layer response):
      // Never navigate to a blank page or pop blindly. Show verified UI.
      if (result.data['alreadyOwned'] == true) {
        if (billingEmail.isNotEmpty) {
          try {
            await MembershipService().lookupEntitlementByEmail(billingEmail);
          } catch (_) {}
        }
        if (mounted) {
          setState(() {
            _alreadyOwned = true;
            _verifiedEmail = billingEmail;
            _isStartingCheckout = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              'Lifetime Membership Verified. World Radio Explorer is unlocked.',
            ),
          ));
          RadioLaunchController.requestOpen();
          _scheduleAutoRedirect();
        }
        return;
      }

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

      // Keep listening in this tab: the instant the Stripe webhook marks
      // the purchase complete, this app auto-unlocks World Radio Explorer
      // without requiring the user to return and tap anything.
      if (billingEmail.isNotEmpty) {
        EntitlementWatcher.instance.watch(billingEmail);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Complete your payment in the new tab. This app will unlock '
            'automatically once the purchase completes.',
          ),
          duration: Duration(seconds: 6),
        ));
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
      if (mounted && !_alreadyOwned) {
        setState(() => _isStartingCheckout = false);
      }
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

  Widget _buildAlreadyOwnedView(BuildContext context) {
    final email = _verifiedEmail;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.verified_rounded, color: Colors.green, size: 64),
        const SizedBox(height: 16),
        Text(
          '✅ Lifetime Membership Verified',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
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
          'World Radio Explorer has been unlocked.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        const Text(
          'Opening World Radio Explorer...',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        const LinearProgressIndicator(),
        const SizedBox(height: 24),
        FilledButton.icon(
          icon: const Icon(Icons.radio),
          onPressed: () => _openRadioDirectory(context),
          label: const Text('Open Radio Directory'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => _openRadioDirectory(context),
          child: const Text('Return To Radio Directory'),
        ),
      ],
    );
  }

  Widget _buildCheckoutForm(BuildContext context) {
    return Column(
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
          'Unlocks World Radio Explorer. All other OmniToolkit modules remain free forever.',
          textAlign: TextAlign.center,
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
        const SizedBox(height: 24),
        Text(
          'Confirm Your Billing Email',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          _emailLocked
              ? 'This is the email you just verified. Retype it below to '
                  'confirm before payment -- it cannot be changed later.'
              : 'Enter the email to link Lifetime Access to, then retype it '
                  'to confirm -- it cannot be changed later.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          readOnly: _emailLocked,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            border: const OutlineInputBorder(),
            filled: _emailLocked,
            fillColor: _emailLocked ? Colors.grey.shade200 : null,
            suffixIcon: _emailLocked
                ? const Icon(Icons.verified_rounded, color: Colors.green)
                : null,
            errorText: _normalizedEmail.isNotEmpty && !_emailIsValid
                ? 'Enter a valid email address.'
                : null,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _confirmEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Confirm Email',
            border: const OutlineInputBorder(),
            suffixIcon: _emailsMatch
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            errorText: _confirmEmailError,
          ),
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
          onPressed: _canContinue ? _startCheckout : null,
          child: Text(_isStartingCheckout
              ? 'Opening checkout...'
              : 'Continue With Payment'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _alreadyOwned ? 'Lifetime Membership Verified' : 'Billing Notice'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _alreadyOwned
                    ? _buildAlreadyOwnedView(context)
                    : _buildCheckoutForm(context),
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