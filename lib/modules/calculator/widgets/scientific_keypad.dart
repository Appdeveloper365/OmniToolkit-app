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
    CalcKeySpec m(String label, VoidCallback onTap) =>
        s(label, CalcKeyRole.memory, onTap, fontSize: 13);
    CalcKeySpec numKey(String label, int padRow, int padCol) => CalcKeySpec(
        label: label,
        role: (padRow + padCol).isEven ? CalcKeyRole.numberDark : CalcKeyRole.numberLight,
        onTap: () => notifier.input(label));

    // A two-key action row on top, then seven full rows of six.
    // 2 + (7 x 6) = 44, so every key is placed and no row is ragged. The
    // longer run of the grid is vertical, so the keypad is taller than it is
    // wide — the orientation a portrait phone actually has room for. Fewer
    // columns also means larger keys (~58px on a 390px screen rather than
    // ~49px), which suits fingertip input. Cell width derives from the space
    // available, so the keypad fits any screen without clipping or scrolling.
    //
    // Column discipline, so the eye can find things by position alone:
    //   * the scientific/alpha keys stack down the rows above the pad in
    //     reading order;
    //   * MC MR M+ M- share one line by themselves, with DEL next to them;
    //   * ÷ x - + hold the right-hand column of every row that has one, so the
    //     four operators line up vertically and never sit on a row edge alone;
    //   * digits keep the familiar 789 / 456 / 123 / 0 adjacency.
    final rows = <List<CalcKeySpec>>[
      // --- top: the two keys needed most, always in reach. Each spans half
      //     the row so AC anchors to the far left and = to the far right,
      //     matching the width of the six-column rows below. ---
      [
        CalcKeySpec(
          label: 'AC',
          role: CalcKeyRole.clear,
          fontSize: 18,
          columnSpan: 3,
          onTap: notifier.clearAll,
        ),
        CalcKeySpec(
          label: '=',
          role: CalcKeyRole.equals,
          columnSpan: 3,
          onTap: notifier.equals,
        ),
      ],
      // --- scientific functions ---
      [
        s('sin', CalcKeyRole.scientificTrig, () => notifier.applyUnary('sin', service.sinDeg)),
        s('cos', CalcKeyRole.scientificTrig, () => notifier.applyUnary('cos', service.cosDeg)),
        s('tan', CalcKeyRole.scientificTrig, () => notifier.applyUnary('tan', service.tanDeg)),
        s('asin', CalcKeyRole.scientificTrig, () => notifier.applyUnary('asin', service.asinDeg)),
        s('acos', CalcKeyRole.scientificTrig, () => notifier.applyUnary('acos', service.acosDeg)),
        s('atan', CalcKeyRole.scientificTrig, () => notifier.applyUnary('atan', service.atanDeg)),
      ],
      [
        s('log', CalcKeyRole.scientificLog, () => notifier.applyUnary('log', service.log10)),
        s('ln', CalcKeyRole.scientificLog, () => notifier.applyUnary('ln', service.ln)),
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
        s('π', CalcKeyRole.scientificOther, () => notifier.input('π')),
        s('e', CalcKeyRole.scientificLog, () => notifier.input('e')),
      ],
      // --- memory: all four together on one line, sitting directly above
      //     the number pad, with DEL alongside them ---
      [
        m('MC', notifier.memoryClear),
        m('MR', notifier.memoryRecall),
        m('M+', notifier.memoryAdd),
        m('M-', notifier.memorySubtract),
        CalcKeySpec(label: 'DEL', role: CalcKeyRole.delete, fontSize: 15, onTap: notifier.backspace),
        CalcKeySpec(label: '÷', role: CalcKeyRole.divide, onTap: () => notifier.input('÷')),
      ],
      // --- number pad. Digits hold the usual 789 / 456 / 123 adjacency in
      //     the left three columns; the operator column never moves. ---
      [
        numKey('7', 0, 0),
        numKey('8', 0, 1),
        numKey('9', 0, 2),
        s('%', CalcKeyRole.function, () => notifier.input('%')),
        // Must invoke toggleSign: passing the tear-off bare would only
        // evaluate the method reference and never run the sign flip.
        s('±', CalcKeyRole.function, () => notifier.toggleSign()),
        CalcKeySpec(label: '×', role: CalcKeyRole.multiply, onTap: () => notifier.input('×')),
      ],
      [
        numKey('4', 1, 0),
        numKey('5', 1, 1),
        numKey('6', 1, 2),
        s('(', CalcKeyRole.scientificOther, () => notifier.input('(')),
        s(')', CalcKeyRole.scientificOther, () => notifier.input(')')),
        CalcKeySpec(label: '-', role: CalcKeyRole.subtract, onTap: () => notifier.input('-')),
      ],
      [
        numKey('1', 2, 0),
        numKey('2', 2, 1),
        numKey('3', 2, 2),
        numKey('0', 3, 0),
        s('.', CalcKeyRole.function, () => notifier.input('.')),
        CalcKeySpec(label: '+', role: CalcKeyRole.add, onTap: () => notifier.input('+')),
      ],
    ];

    return Center(
      child: CalculatorKeypadGrid(
        rows: rows,
        maxWidth: 400.0,
        minCellSize: 50.0,
        spacing: 6.0,
      ),
    );
  }
}
