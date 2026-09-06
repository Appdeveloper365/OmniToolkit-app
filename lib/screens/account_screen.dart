/// FILE: lib/screens/account_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/auth/auth_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  static final _dateFormat = DateFormat('MMMM d, yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(appAuthProvider);
    final user = authState.userModel;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Account & Billing')),
      body: user == null
          ? const Center(child: Text('No account logged in'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // User Info Header Card
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: theme.colorScheme.primary,
                                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(user.email, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 2),
                                        Text('UID: ${user.uid}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Subscription / License Card
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Access & Entitlement Status', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 14),
                              _StatusRow(
                                label: 'License Type',
                                value: user.isPaid ? 'Lifetime Pass' : '7-Day Free Trial',
                                isHighlight: user.isPaid,
                              ),
                              _StatusRow(
                                label: 'Payment Status',
                                value: user.paymentStatus.toUpperCase(),
                              ),
                              if (!user.isPaid)
                                _StatusRow(
                                  label: 'Trial Days Remaining',
                                  value: '${user.remainingTrialDays} Days',
                                ),
                              if (user.purchaseDate != null)
                                _StatusRow(
                                  label: 'Purchase Date',
                                  value: _dateFormat.format(user.purchaseDate!),
                                ),
                              if (!user.isPaid) ...[
                                const SizedBox(height: 12),
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.star_rounded),
                                  label: const Text(r'Buy Lifetime Access ($9.99 USD)'),
                                  onPressed: () => Navigator.pushNamed(context, '/pricing'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Account Disclaimer Info Box
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Google Account Linking Notice:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Lifetime access is permanently linked to your Google account. Please use the same Google account when signing in across your devices.\n\n'
                              'Automatic transfer of purchases between different email accounts is not supported. If you lose access to your Google account, contact support before creating a new account.',
                              style: TextStyle(fontSize: 11, height: 1.4),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Sign Out Button
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          ref.read(appAuthProvider.notifier).signOut();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value, this.isHighlight = false});
  final String label;
  final String value;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isHighlight ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}
