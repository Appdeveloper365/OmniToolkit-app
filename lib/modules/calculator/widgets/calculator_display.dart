/// FILE: lib/modules/calculator/widgets/calculator_display.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/calculator_provider.dart';

/// Premium glass-effect display panel: smaller expression text on top,
/// a significantly larger result below, right-aligned, with a smooth
/// scrollable row for long expressions.
class CalculatorDisplay extends ConsumerWidget {
  const CalculatorDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(calculatorSessionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expression = session.expression.isEmpty ? '0' : session.expression;
    final result = session.result;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: isDark ? 0.02 : 0.9),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Text(
              expression,
              maxLines: 1,
              style: TextStyle(
                fontSize: 20,
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 8),
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
                  fontSize: 46,
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