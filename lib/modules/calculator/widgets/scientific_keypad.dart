/// FILE: lib/modules/calculator/widgets/scientific_keypad.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/calculator_provider.dart';
import 'calculator_keypad_grid.dart';
import 'premium_calculator_button.dart';

/// Scientific controls wrap around the standard 4x5 number pad as a frame:
/// a top row above the pad and two columns down each side, all in a single
/// 8-column grid of equally sized keys so the whole calculator reads as one
/// square block with the number pad at its center.
///
/// The 24 scientific keys tile exactly as: 4 top + 10 left (2 cols x 5) +
/// 10 right (2 cols x 5). The four top corner cells are left empty, keeping
/// the frame symmetric.
class ScientificKeypad extends ConsumerWidget {
  const ScientificKeypad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(calculatorSessionProvider.notifier);
    final service = ref.read(expressionServiceProvider);

    CalcKeySpec f(String label, VoidCallback onTap, {double fontSize = 14}) =>
        CalcKeySpec(label: label, role: CalcKeyRole.function, fontSize: fontSize, onTap: onTap);
    CalcKeySpec m(String label, VoidCallback onTap) =>
        CalcKeySpec(label: label, role: CalcKeyRole.memory, fontSize: 13, onTap: onTap);
    // Number keys alternate Dark/Light starting with Dark on the 7-8-9 row,
    // matching the standard CalculatorKeypad. [padRow]/[padCol] are the key's
    // position inside the 4x5 number pad.
    CalcKeySpec num(String label, int padRow, int padCol) => CalcKeySpec(
        label: label,
        role: (padRow + padCol).isEven ? CalcKeyRole.numberDark : CalcKeyRole.numberLight,
        onTap: () => notifier.input(label));

    // 8 columns x 6 rows. `null` marks an empty corner cell.
    // Cols 2-5 hold the number pad (rows 1-5); the rest is the scientific frame.
    final rows = <List<CalcKeySpec?>>[
      [
        null, null,
        f('sin', () => notifier.applyUnary('sin', service.sinDeg)),
        f('cos', () => notifier.applyUnary('cos', service.cosDeg)),
        f('tan', () => notifier.applyUnary('tan', service.tanDeg)),
        f('asin', () => notifier.applyUnary('asin', service.asinDeg)),
        null, null,
      ],
      [
        f('acos', () => notifier.applyUnary('acos', service.acosDeg)),
        m('MC', notifier.memoryClear),
        CalcKeySpec(label: 'AC', role: CalcKeyRole.clear, fontSize: 18, onTap: notifier.clearAll),
        CalcKeySpec(label: '±', role: CalcKeyRole.function, onTap: notifier.toggleSign),
        f('%', () => notifier.input('%')),
        CalcKeySpec(label: '÷', role: CalcKeyRole.divide, onTap: () => notifier.input('÷')),
        f(')', () => notifier.input(')')),
        f('log', () => notifier.applyUnary('log', service.log10)),
      ],
      [
        f('atan', () => notifier.applyUnary('atan', service.atanDeg)),
        m('MR', notifier.memoryRecall),
        num('7', 0, 0), num('8', 0, 1), num('9', 0, 2),
        CalcKeySpec(label: '×', role: CalcKeyRole.multiply, onTap: () => notifier.input('×')),
        f('ln', () => notifier.applyUnary('ln', service.ln)),
        f('√', () => notifier.applyUnary('√', service.sqrtOf)),
      ],
      [
        f('π', () => notifier.input('π')),
        m('M+', notifier.memoryAdd),
        num('4', 1, 0), num('5', 1, 1), num('6', 1, 2),
        CalcKeySpec(label: '-', role: CalcKeyRole.subtract, onTap: () => notifier.input('-')),
        f('ⁿ√', () => notifier.input('^(1/')),
        f('xʸ', () => notifier.input('^')),
      ],
      [
        f('e', () => notifier.input('e')),
        m('M-', notifier.memorySubtract),
        num('1', 2, 0), num('2', 2, 1), num('3', 2, 2),
        CalcKeySpec(label: '+', role: CalcKeyRole.add, onTap: () => notifier.input('+')),
        f('x²', () => notifier.applyUnary('x²', service.square)),
        f('x³', () => notifier.applyUnary('x³', service.cube)),
      ],
      [
        f('(', () => notifier.input('(')),
        f('|x|', () => notifier.applyUnary('|x|', service.absoluteValue)),
        num('0', 3, 0),
        f('.', () => notifier.input('.')),
        CalcKeySpec(label: 'DEL', role: CalcKeyRole.delete, fontSize: 15, onTap: notifier.backspace),
        CalcKeySpec(label: '=', role: CalcKeyRole.equals, onTap: notifier.equals),
        f('1/x', () => notifier.applyUnary('1/x', service.reciprocal)),
        f('x!', () => notifier.applyUnary('x!', service.factorial)),
      ],
    ];

    const columns = 8;
    const spacing = 6.0;
    const maxWidth = 560.0;
    const minCellSize = 38.0;

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth < maxWidth ? constraints.maxWidth : maxWidth;
          final cellSize = ((width - spacing * (columns - 1)) / columns)
              .clamp(minCellSize, double.infinity)
              .toDouble();
          final gridWidth = cellSize * columns + spacing * (columns - 1);

          return SizedBox(
            width: gridWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var r = 0; r < rows.length; r++) ...[
                  if (r > 0) const SizedBox(height: spacing),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var c = 0; c < columns; c++) ...[
                        if (c > 0) const SizedBox(width: spacing),
                        SizedBox(
                          width: cellSize,
                          height: cellSize,
                          child: rows[r][c] == null
                              ? null
                              : PremiumCalculatorButton(
                                  label: rows[r][c]!.label,
                                  role: rows[r][c]!.role,
                                  fontSize: rows[r][c]!.fontSize,
                                  semanticsLabel: rows[r][c]!.semanticsLabel,
                                  onTap: rows[r][c]!.onTap,
                                ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
