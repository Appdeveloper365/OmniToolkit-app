/// FILE: lib/modules/calculator/widgets/scientific_keypad.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/calculator_provider.dart';
import 'calculator_keypad_grid.dart';
import 'premium_calculator_button.dart';

/// Scientific controls are arranged as a portrait-oriented keypad.
/// The layout consists of 6 rows of scientific functions above a standard 4x5
/// number pad, resulting in a 4-column grid that fits mobile screens.
///
/// Scientific keys are color-coded by category (trigonometry, logarithms,
/// powers, etc.) to be more distinctive.
class ScientificKeypad extends ConsumerWidget {
  const ScientificKeypad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(calculatorSessionProvider.notifier);
    final service = ref.read(expressionServiceProvider);

    CalcKeySpec s(String label, CalcKeyRole role, VoidCallback onTap, {double fontSize = 14}) =>
        CalcKeySpec(label: label, role: role, fontSize: fontSize, onTap: onTap);
    CalcKeySpec f(String label, VoidCallback onTap) =>
        s(label, CalcKeyRole.function, onTap);
    CalcKeySpec m(String label, VoidCallback onTap) =>
        s(label, CalcKeyRole.memory, onTap, fontSize: 13);
    // Number keys alternate Dark/Light starting with Dark on the 7-8-9 row,
    // matching the standard CalculatorKeypad. [padRow]/[padCol] are the key's
    // position inside the 4x5 number pad.
    CalcKeySpec num(String label, int padRow, int padCol) => CalcKeySpec(
        label: label,
        role: (padRow + padCol).isEven ? CalcKeyRole.numberDark : CalcKeyRole.numberLight,
        onTap: () => notifier.input(label));

    // 4 columns x 11 rows.
    // Rows 0-5 contain scientific functions, Row 6 contains controls,
    // and Rows 7-10 contain the standard number pad.
    final rows = <List<CalcKeySpec>>[
      [
        s('sin', CalcKeyRole.scientificTrig, () => notifier.applyUnary('sin', service.sinDeg)),
        s('cos', CalcKeyRole.scientificTrig, () => notifier.applyUnary('cos', service.cosDeg)),
        s('tan', CalcKeyRole.scientificTrig, () => notifier.applyUnary('tan', service.tanDeg)),
        s('asin', CalcKeyRole.scientificTrig, () => notifier.applyUnary('asin', service.asinDeg)),
      ],
      [
        s('acos', CalcKeyRole.scientificTrig, () => notifier.applyUnary('acos', service.acosDeg)),
        s('atan', CalcKeyRole.scientificTrig, () => notifier.applyUnary('atan', service.atanDeg)),
        s('log', CalcKeyRole.scientificLog, () => notifier.applyUnary('log', service.log10)),
        s('ln', CalcKeyRole.scientificLog, () => notifier.applyUnary('ln', service.ln)),
      ],
      [
        s('√', CalcKeyRole.scientificPower, () => notifier.applyUnary('√', service.sqrtOf)),
        s('ⁿ√', CalcKeyRole.scientificPower, () => notifier.input('^(1/')),
        s('xʸ', CalcKeyRole.scientificPower, () => notifier.input('^')),
        s('x²', CalcKeyRole.scientificPower, () => notifier.applyUnary('x²', service.square)),
      ],
      [
        s('x³', CalcKeyRole.scientificPower, () => notifier.applyUnary('x³', service.cube)),
        s('1/x', CalcKeyRole.scientificPower, () => notifier.applyUnary('1/x', service.reciprocal)),
        s('x!', CalcKeyRole.scientificPower, () => notifier.applyUnary('x!', service.factorial)),
        s('|x|', CalcKeyRole.scientificPower, () => notifier.applyUnary('|x|', service.absoluteValue)),
      ],
      [
        s('π', CalcKeyRole.scientificOther, () => notifier.input('π')),
        s('e', CalcKeyRole.scientificLog, () => notifier.input('e')),
        s('(', CalcKeyRole.scientificOther, () => notifier.input('(')),
        s(')', CalcKeyRole.scientificOther, () => notifier.input(')')),
      ],
      [
        m('MC', notifier.memoryClear),
        m('MR', notifier.memoryRecall),
        m('M+', notifier.memoryAdd),
        m('M-', notifier.memorySubtract),
      ],
      [
        CalcKeySpec(label: 'AC', role: CalcKeyRole.clear, fontSize: 18, onTap: notifier.clearAll),
        CalcKeySpec(label: '±', role: CalcKeyRole.function, onTap: notifier.toggleSign),
        s('%', CalcKeyRole.function, () => notifier.input('%')),
        CalcKeySpec(label: '÷', role: CalcKeyRole.divide, onTap: () => notifier.input('÷')),
      ],
      [
        num('7', 0, 0), num('8', 0, 1), num('9', 0, 2),
        CalcKeySpec(label: '×', role: CalcKeyRole.multiply, onTap: () => notifier.input('×')),
      ],
      [
        num('4', 1, 0), num('5', 1, 1), num('6', 1, 2),
        CalcKeySpec(label: '-', role: CalcKeyRole.subtract, onTap: () => notifier.input('-')),
      ],
      [
        num('1', 2, 0), num('2', 2, 1), num('3', 2, 2),
        CalcKeySpec(label: '+', role: CalcKeyRole.add, onTap: () => notifier.input('+')),
      ],
      [
        num('0', 3, 0),
        s('.', CalcKeyRole.function, () => notifier.input('.')),
        CalcKeySpec(label: 'DEL', role: CalcKeyRole.delete, fontSize: 15, onTap: notifier.backspace),
        CalcKeySpec(label: '=', role: CalcKeyRole.equals, onTap: notifier.equals),
      ],
    ];

    const columns = 4;
    const spacing = 6.0;
    const maxWidth = 400.0;
    const minCellSize = 50.0;

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
                          child: PremiumCalculatorButton(
                            label: rows[r][c].label,
                            role: rows[r][c].role,
                            fontSize: rows[r][c].fontSize,
                            semanticsLabel: rows[r][c].semanticsLabel,
                            onTap: rows[r][c].onTap,
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
