/// FILE: lib/modules/password/password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'password_provider.dart';

class PasswordScreen extends ConsumerWidget {
  const PasswordScreen({super.key});

  void _generate(WidgetRef ref) {
    final service = ref.read(passwordGeneratorServiceProvider);
    final pwd = service.generate(
      length: ref.read(passwordLengthProvider).round(),
      includeUppercase: ref.read(includeUppercaseProvider),
      includeNumbers: ref.read(includeNumbersProvider),
      includeSymbols: ref.read(includeSymbolsProvider),
    );
    ref.read(generatedPasswordProvider.notifier).state = pwd;
    ref.read(passwordHistoryProvider.notifier).addPassword(pwd);
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final length = ref.watch(passwordLengthProvider);
    final includeUppercase = ref.watch(includeUppercaseProvider);
    final includeNumbers = ref.watch(includeNumbersProvider);
    final includeSymbols = ref.watch(includeSymbolsProvider);
    final password = ref.watch(generatedPasswordProvider);
    final history = ref.watch(passwordHistoryProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Generator'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear Session History',
              onPressed: () {
                ref.read(passwordHistoryProvider.notifier).clearHistory();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Session history cleared')),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Primary Generator Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Generate Secure Password', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        // Password Output Box
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: SelectableText(
                                  password.isEmpty ? 'Tap generate below' : password,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                    color: password.isEmpty ? Colors.grey : null,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy_rounded),
                                tooltip: 'Copy Password',
                                onPressed: password.isEmpty
                                    ? null
                                    : () => _copyToClipboard(context, password),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Options
                        Row(
                          children: [
                            Text('Length: ${length.round()}', style: const TextStyle(fontWeight: FontWeight.w600)),
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
                          title: const Text('Uppercase letters (A-Z)'),
                          value: includeUppercase,
                          onChanged: (v) => ref.read(includeUppercaseProvider.notifier).state = v,
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Numbers (0-9)'),
                          value: includeNumbers,
                          onChanged: (v) => ref.read(includeNumbersProvider.notifier).state = v,
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(r'Symbols (!@#$)'),
                          value: includeSymbols,
                          onChanged: (v) => ref.read(includeSymbolsProvider.notifier).state = v,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _generate(ref),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Generate Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Session History Section
                if (history.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Session History (${history.length})', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text('(In-memory only)', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(item, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600)),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 20),
                            tooltip: 'Copy',
                            onPressed: () => _copyToClipboard(context, item),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
