/// FILE: lib/modules/clipper/widgets/password_generator_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/clipper_provider.dart';

/// Password generator with length slider and toggles for symbols, numbers
/// and uppercase letters.
class PasswordGeneratorWidget extends ConsumerWidget {
  const PasswordGeneratorWidget({super.key});

  void _regenerate(WidgetRef ref) {
    final service = ref.read(passwordGeneratorServiceProvider);
    final password = service.generate(
      length: ref.read(passwordLengthProvider).round(),
      includeUppercase: ref.read(includeUppercaseProvider),
      includeNumbers: ref.read(includeNumbersProvider),
      includeSymbols: ref.read(includeSymbolsProvider),
    );
    ref.read(generatedPasswordProvider.notifier).state = password;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final length = ref.watch(passwordLengthProvider);
    final includeUppercase = ref.watch(includeUppercaseProvider);
    final includeNumbers = ref.watch(includeNumbersProvider);
    final includeSymbols = ref.watch(includeSymbolsProvider);
    final password = ref.watch(generatedPasswordProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Password Generator', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    password.isEmpty ? 'Tap generate to create a password' : password,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy to clipboard',
                  onPressed: password.isEmpty
                      ? null
                      : () {
                          Clipboard.setData(ClipboardData(text: password));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password copied')),
                          );
                        },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Length: ${length.round()}'),
                Expanded(
                  child: Slider(
                    value: length,
                    min: 6,
                    max: 32,
                    divisions: 26,
                    label: length.round().toString(),
                    onChanged: (value) => ref.read(passwordLengthProvider.notifier).state = value,
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Uppercase letters'),
              value: includeUppercase,
              onChanged: (v) => ref.read(includeUppercaseProvider.notifier).state = v,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Numbers'),
              value: includeNumbers,
              onChanged: (v) => ref.read(includeNumbersProvider.notifier).state = v,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Symbols'),
              value: includeSymbols,
              onChanged: (v) => ref.read(includeSymbolsProvider.notifier).state = v,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => _regenerate(ref),
              icon: const Icon(Icons.refresh),
              label: const Text('Generate Password'),
            ),
          ],
        ),
      ),
    );
  }
}
