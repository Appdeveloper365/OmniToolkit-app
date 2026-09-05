/// FILE: lib/modules/calculator/widgets/calculator_display.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/calculator_provider.dart';

/// Premium glass-effect display panel with in-display session history toggle.
class CalculatorDisplay extends ConsumerStatefulWidget {
  const CalculatorDisplay({super.key});

  @override
  ConsumerState<CalculatorDisplay> createState() => _CalculatorDisplayState();
}

class _CalculatorDisplayState extends ConsumerState<CalculatorDisplay> {
  bool _showHistory = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(calculatorSessionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expression = session.expression.isEmpty ? '0' : session.expression;
    final result = session.result;
    final history = session.history;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF16181D), Color(0xFF0D0F13)]
              : const [Color(0xFFFFFFFF), Color(0xFFEFF2F6)],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.06 : 0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top bar: History toggle button & Expression line
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                icon: Icon(
                  Icons.history_rounded,
                  size: 18,
                  color: _showHistory
                      ? (isDark ? const Color(0xFF00E5FF) : const Color(0xFF0284C7))
                      : Colors.grey,
                ),
                tooltip: _showHistory ? 'Hide History' : 'Show Session History',
                onPressed: () => setState(() => _showHistory = !_showHistory),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Text(
                    expression,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 16,
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // In-display session history list overlay when toggled
          if (_showHistory)
            Container(
              margin: const EdgeInsets.only(top: 4, bottom: 4),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(maxHeight: 110),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
              child: history.isEmpty
                  ? const Center(
                      child: Text('No session history yet', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      reverse: true,
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[history.length - 1 - index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            item,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.w600),
                          ),
                        );
                      },
                    ),
            ),

          const SizedBox(height: 2),

          // Main Result Text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: SingleChildScrollView(
              key: ValueKey(result),
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                result.isEmpty ? '0' : result,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: result == 'Error'
                      ? Theme.of(context).colorScheme.error
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
