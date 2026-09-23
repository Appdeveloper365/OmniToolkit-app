/// FILE: lib/modules/calculator/widgets/scientific_keypad.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/calculator_provider.dart';
import 'calculator_keypad.dart';
import 'calculator_keypad_grid.dart';
import 'premium_calculator_button.dart';

/// Scientific function header arranged as a compact T-shape above the main
/// calculator keypad: three short horizontal rows keep the display area open
/// while retaining the full scientific function set.
class ScientificKeypad extends ConsumerWidget {
  const ScientificKeypad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(calculatorSessionProvider.notifier);
    final service = ref.read(expressionServiceProvider);

    final functionRows = <List<CalcKeySpec>>[
      [
        CalcKeySpec(label: 'sin', role: CalcKeyRole.function, fontSize: 15, onTap: () => notifier.applyUnary('sin', service.sinDeg)),
        CalcKeySpec(label: 'cos', role: CalcKeyRole.function, fontSize: 15, onTap: () => notifier.applyUnary('cos', service.cosDeg)),
        CalcKeySpec(label: 'tan', role: CalcKeyRole.function, fontSize: 15, onTap: () => notifier.applyUnary('tan', service.tanDeg)),
        CalcKeySpec(label: 'asin', role: CalcKeyRole.function, fontSize: 12, onTap: () => notifier.applyUnary('asin', service.asinDeg)),
        CalcKeySpec(label: 'acos', role: CalcKeyRole.function, fontSize: 12, onTap: () => notifier.applyUnary('acos', service.acosDeg)),
        CalcKeySpec(label: 'atan', role: CalcKeyRole.function, fontSize: 12, onTap: () => notifier.applyUnary('atan', service.atanDeg)),
        CalcKeySpec(label: '(', role: CalcKeyRole.function, onTap: () => notifier.input('(')),
        CalcKeySpec(label: ')', role: CalcKeyRole.function, onTap: () => notifier.input(')')),
      ],
      [
        CalcKeySpec(label: 'π', role: CalcKeyRole.function, onTap: () => notifier.input('π')),
        CalcKeySpec(label: 'e', role: CalcKeyRole.function, onTap: () => notifier.input('e')),
        CalcKeySpec(label: 'log', role: CalcKeyRole.function, fontSize: 14, onTap: () => notifier.applyUnary('log', service.log10)),
        CalcKeySpec(label: 'ln', role: CalcKeyRole.function, fontSize: 15, onTap: () => notifier.applyUnary('ln', service.ln)),
        CalcKeySpec(label: '√', role: CalcKeyRole.function, onTap: () => notifier.applyUnary('√', service.sqrtOf)),
        CalcKeySpec(label: 'ⁿ√', role: CalcKeyRole.function, fontSize: 14, onTap: () => notifier.input('^(1/')),
        CalcKeySpec(label: 'xʸ', role: CalcKeyRole.function, fontSize: 14, onTap: () => notifier.input('^')),
        CalcKeySpec(label: 'x²', role: CalcKeyRole.function, onTap: () => notifier.applyUnary('x²', service.square)),
      ],
      [
        CalcKeySpec(label: 'x³', role: CalcKeyRole.function, onTap: () => notifier.applyUnary('x³', service.cube)),
        CalcKeySpec(label: '1/x', role: CalcKeyRole.function, fontSize: 13, onTap: () => notifier.applyUnary('1/x', service.reciprocal)),
        CalcKeySpec(label: 'x!', role: CalcKeyRole.function, onTap: () => notifier.applyUnary('x!', service.factorial)),
        CalcKeySpec(label: '|x|', role: CalcKeyRole.function, fontSize: 13, onTap: () => notifier.applyUnary('|x|', service.absoluteValue)),
        CalcKeySpec(label: 'MC', role: CalcKeyRole.memory, fontSize: 13, onTap: notifier.memoryClear),
        CalcKeySpec(label: 'MR', role: CalcKeyRole.memory, fontSize: 13, onTap: notifier.memoryRecall),
        CalcKeySpec(label: 'M+', role: CalcKeyRole.memory, fontSize: 13, onTap: notifier.memoryAdd),
        CalcKeySpec(label: 'M-', role: CalcKeyRole.memory, fontSize: 13, onTap: notifier.memorySubtract),
      ],
    ];

    return Column(
      children: [
        CalculatorKeypadGrid(rows: functionRows, minCellSize: 38, spacing: 6),
        const SizedBox(height: 10),
        const CalculatorKeypad(),
      ],
    );
  }
}
