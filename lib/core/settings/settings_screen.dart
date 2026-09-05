import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Use 24-hour time'),
                        subtitle: const Text('Display time in 24-hour format across modules'),
                        value: settings.use24HourFormat,
                        onChanged: (v) => ref.read(settingsProvider.notifier).updateSettings(use24HourFormat: v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('About OmniToolkit', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('OmniToolkit is a modern daily productivity suite featuring Weather, Calendar with Notes & Date Difference, Calculator & Unit Converter, World Radio, US Lookup, and Password Generator.'),
                        const SizedBox(height: 12),
                        const Text('Version: 1.0.0+1', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
