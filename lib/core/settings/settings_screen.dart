/// FILE: lib/core/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Use 24-hour time'),
                        subtitle: const Text(
                            'Display time in 24-hour format across modules'),
                        value: settings.use24HourFormat,
                        onChanged: (v) => ref
                            .read(settingsProvider.notifier)
                            .updateSettings(use24HourFormat: v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const Icon(Icons.manage_accounts_rounded,
                        color: Colors.blue),
                    title: const Text('Account & Billing',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text(
                        'View trial status, license details, and logout'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () =>
                        Navigator.pushNamed(context, '/billing-notice'),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const Icon(Icons.workspace_premium_rounded,
                        color: Colors.amber),
                    title: const Text('Premium Membership',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text(
                        'Manage lifetime access and active devices'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () =>
                        Navigator.pushNamed(context, '/premium-membership'),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const Icon(Icons.verified_user_outlined,
                        color: Colors.green),
                    title: const Text('Membership Status',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text(
                        'Check Lifetime Membership by purchase email'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () =>
                        Navigator.pushNamed(context, '/membership-status'),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined,
                            color: Colors.teal),
                        title: const Text('Privacy Policy'),
                        trailing: const Icon(Icons.open_in_new_rounded,
                            size: 18),
                        onTap: () => _openLegalDoc(
                            context, 'https://appdeveloper365.github.io/OmniToolkit-app/privacy.html'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.description_outlined,
                            color: Colors.indigo),
                        title: const Text('Terms of Use'),
                        trailing: const Icon(Icons.open_in_new_rounded,
                            size: 18),
                        onTap: () => _openLegalDoc(
                            context, 'https://appdeveloper365.github.io/OmniToolkit-app/terms.html'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.gavel_outlined,
                            color: Colors.deepOrange),
                        title: const Text('Legal Notices'),
                        trailing: const Icon(Icons.open_in_new_rounded,
                            size: 18),
                        onTap: () => _openLegalDoc(context,
                            'https://appdeveloper365.github.io/OmniToolkit-app/docs/index.html'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('About OmniToolkit',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text(
                            'OmniToolkit is a modern daily productivity suite featuring Calendar with Clock & Notes, 3D Calculator & Unit Converter, World Radio Explorer, US Lookup, and Password Generator.'),
                        const SizedBox(height: 12),
                        const Text('Version: 1.0.0+1',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// Opens a legal document (Privacy Policy, Terms of Use, Legal Notices) in
  /// the platform browser/tab. These pages live outside the app shell so
  /// they never take over the app's own startup route or navigation.
  Future<void> _openLegalDoc(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open: $url')),
      );
    }
  }
}
