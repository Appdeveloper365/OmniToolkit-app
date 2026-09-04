/// FILE: lib/modules/calculator/widgets/history_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/calculator_provider.dart';

/// Collapsible, scrollable panel showing the current session's calculation
/// history. Session-only: cleared automatically whenever the notifier
/// resets (AC, or starting a new calculation right after a result).
class HistoryPanel extends ConsumerStatefulWidget {
  const HistoryPanel({super.key});

  @override
  ConsumerState<HistoryPanel> createState() => _HistoryPanelState();
}

class _HistoryPanelState extends ConsumerState<HistoryPanel> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(calculatorSessionProvider.select((s) => s.history));
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.history, size: 18, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text('History', style: Theme.of(context).textTheme.labelLarge),
                  const Spacer(),
                  if (history.isNotEmpty)
                    Text('${history.length}', style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(width: 4),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: scheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: SizedBox(
              height: history.isEmpty ? 56 : (history.length * 32.0).clamp(32, 180),
              child: history.isEmpty
                  ? Center(
                      child: Text(
                        'No calculations yet this session.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final entry = history[history.length - 1 - index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(entry, style: Theme.of(context).textTheme.bodyMedium),
                        );
                      },
                    ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}