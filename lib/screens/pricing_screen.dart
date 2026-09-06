/// FILE: lib/screens/pricing_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/auth/auth_provider.dart';

class PricingScreen extends ConsumerWidget {
  const PricingScreen({super.key});

  Future<void> _buyNow(BuildContext context, WidgetRef ref) async {
    final user = ref.read(appAuthProvider).userModel;
    if (user == null) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    const checkoutUrl = 'https://checkout.stripe.com/pay/cs_test_omnitoolkit';
    try {
      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ref.read(appAuthProvider.notifier).grantLifetimeAccessMock();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/payment-success');
        }
      }
    } catch (_) {
      ref.read(appAuthProvider.notifier).grantLifetimeAccessMock();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/payment-success');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Unlock Lifetime Access')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFF00E5FF) : const Color(0xFF0284C7)).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ONE-TIME PURCHASE • NO SUBSCRIPTION',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0284C7),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('OmniToolkit Lifetime Pass', textAlign: TextAlign.center, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(r'$4.99', style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                        const SizedBox(width: 4),
                        const Text('USD', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    _BenefitRow(icon: Icons.calendar_month, text: 'Unlimited Calendar & Live Dual Clock'),
                    _BenefitRow(icon: Icons.calculate, text: '3D Standard, Scientific & Date Calculators'),
                    _BenefitRow(icon: Icons.radio, text: 'World Radio Explorer with Live Streaming'),
                    _BenefitRow(icon: Icons.location_on, text: '100% Offline US ZIP, City & Area Lookup'),
                    _BenefitRow(icon: Icons.password, text: 'Secure Password Generator with Memory History'),
                    _BenefitRow(icon: Icons.all_inclusive_rounded, text: 'Lifetime Access on All Devices & Web'),

                    const SizedBox(height: 28),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.shopping_cart_checkout_rounded),
                      label: const Text('Get Lifetime Access Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: () => _buyNow(context, ref),
                    ),
                    const SizedBox(height: 12),
                    const Text('Secure 256-bit Encrypted Checkout via Stripe', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
        ],
      ),
    );
  }
}
