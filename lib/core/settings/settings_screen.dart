import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settings == null ? const Center(child: CircularProgressIndicator()) :
        ListView(children: [
          SwitchListTile(title: const Text('Use 24-hour time'), value: settings.use24HourFormat,
            onChanged: (v) => ref.read(settingsProvider.notifier).updateSettings(use24HourFormat: v)),
          SwitchListTile(title: const Text('Auto-save clips'), value: settings.autoSaveClips,
            onChanged: (v) => ref.read(settingsProvider.notifier).updateSettings(autoSaveClips: v)),
        ]),
    );
  }
}
