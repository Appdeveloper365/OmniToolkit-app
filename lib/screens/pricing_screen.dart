import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/auth/auth_provider.dart';
import '../core/config/build_config.dart';

class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({super.key});

  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> {
  bool _disclaimerChecked = false;
  bool _isStartingCheckout = false;

  Future<void> _buyNow(BuildContext context, WidgetRef ref) async {
    if (BuildConfig.isStoreBuild || _isStartingCheckout) return;

    final user = ref.read(appAuthProvider).userModel;
    if (user == null) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    setState(() => _isStartingCheckout = true);
    try {
      await ref.read(appAuthProvider.notifier).acceptDisclaimer();
      final callable = FirebaseFunctions.instance
          .httpsCallable('createStripeCheckoutSession');
      final result = await callable.call<Map<String, dynamic>>();
      final sessionUrl = result.data['sessionUrl'] as String?;
      if (sessionUrl == null || sessionUrl.isEmpty) {
        throw FirebaseFunctionsException(
            code: 'internal',
            message: 'Checkout session URL was not returned.');
      }

      final uri = Uri.parse(sessionUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw FirebaseFunctionsException(
            code: 'unavailable', message: 'Could not open Stripe Checkout.');
      }
    } on FirebaseFunctionsException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error.message ??
                  'Checkout could not be started. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isStartingCheckout = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (BuildConfig.isStoreBuild) {
      return const _StoreAccessRequiredView();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(appAuthProvider);
    final isAuthenticated =
        authState.isAuthenticated && authState.userModel != null;
    final userEmail = authState.userModel?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Unlock Lifetime Access')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (isDark
                                ? const Color(0xFF00E5FF)
                                : const Color(0xFF0284C7))
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ONE-TIME PURCHASE - NO SUBSCRIPTION',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF00E5FF)
                              : const Color(0xFF0284C7),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('OomniToolkit Lifetime Access',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(r'$9.99',
                            style: theme.textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary)),
                        const SizedBox(width: 4),
                        const Text('USD',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (isAuthenticated && userEmail.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.account_circle_rounded,
                                size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Purchasing as: $userEmail',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: const Text(
                          'Please sign in with Google before purchasing.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),
                    const _BenefitRow(
                        icon: Icons.calendar_month,
                        text: 'Unlimited Calendar & Live Dual Clock'),
                    const _BenefitRow(
                        icon: Icons.calculate,
                        text: '3D Standard, Scientific & Date Calculators'),
                    const _BenefitRow(
                        icon: Icons.radio,
                        text: 'World Radio Explorer with Live Streaming'),
                    const _BenefitRow(
                        icon: Icons.location_on,
                        text: '100% Offline US ZIP, City & Area Lookup'),
                    const _BenefitRow(
                        icon: Icons.password,
                        text: 'Secure Password Generator with Memory History'),
                    const _BenefitRow(
                        icon: Icons.all_inclusive_rounded,
                        text: 'Lifetime Access on All Devices & Web'),
                    const SizedBox(height: 24),
                    if (BuildConfig.isStoreBuild) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1B4B)
                              : const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: isDark
                                  ? const Color(0xFF4338CA)
                                  : const Color(0xFFC7D2FE),
                              width: 1.5),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.storefront_rounded,
                                color: Colors.indigo, size: 36),
                            SizedBox(height: 8),
                            Text(
                              BuildConfig.storeComplianceLockMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Account Linking Disclaimer:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.grey)),
                            SizedBox(height: 6),
                            Text(
                              'Lifetime access is permanently linked to the Google account used to sign in and complete this purchase.\n\n'
                              'Please use the same Google account when accessing OomniToolkit in the future.\n\n'
                              'Automatic transfer of purchases between different email accounts is not supported.\n\n'
                              'If you lose access to your Google account, contact support before creating a new account.',
                              style: TextStyle(fontSize: 11, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isAuthenticated) ...[
                        InkWell(
                          onTap: () => setState(
                              () => _disclaimerChecked = !_disclaimerChecked),
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _disclaimerChecked,
                                onChanged: (val) => setState(
                                    () => _disclaimerChecked = val ?? false),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    'By continuing, I understand that my purchase will be linked to my current Google account.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        height: 1.3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          icon:
                              const Icon(Icons.shopping_cart_checkout_rounded),
                          label: Text(
                              _isStartingCheckout
                                  ? 'Starting Secure Checkout...'
                                  : 'Buy Now (\$9.99 USD)',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          onPressed: _disclaimerChecked && !_isStartingCheckout
                              ? () => _buyNow(context, ref)
                              : null,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                            'Secure 256-bit encrypted checkout via Stripe',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ] else ...[
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.login_rounded),
                          label: const Text('Sign in with Google',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                        ),
                      ],
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

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (BuildConfig.isStoreBuild) {
      return const _StoreAccessRequiredView();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14))),
        ],
      ),
    );
  }
}

class _StoreAccessRequiredView extends StatelessWidget {
  const _StoreAccessRequiredView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Account Required')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user_rounded,
                          size: 48, color: theme.colorScheme.primary),
                      const SizedBox(height: 16),
                      const Text(
                        BuildConfig.storeComplianceLockMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Log In'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
