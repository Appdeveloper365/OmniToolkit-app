/// FILE: lib/core/widgets/trial_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import '../config/build_config.dart';

class TrialBanner extends ConsumerWidget {
  const TrialBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hide 'Install PWA' / Upgrade banner completely on Store APK builds (IS_STORE_BUILD = true)
    if (BuildConfig.isStoreBuild) return const SizedBox.shrink();

    final user = ref.watch(appAuthProvider).userModel;
    if (user == null || user.isPaid) return const SizedBox.shrink();

    final remaining = user.remainingTrialDays;

    return Material(
      color: Colors.amber[800],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.timer_outlined, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'You have $remaining ${remaining == 1 ? "day" : "days"} remaining in your free trial.',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              onPressed: () => Navigator.pushNamed(context, '/pricing'),
              child: const Text(
                r'Lifetime Access ($9.99 One-Time)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
