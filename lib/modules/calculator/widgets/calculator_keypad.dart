/// FILE: lib/modules/calculator/widgets/calculator_keypad.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/calculator_provider.dart';
import 'calculator_keypad_grid.dart';
import 'premium_calculator_button.dart';

/// Standard calculator keypad, laid out exactly per spec:
///
/// ```
/// AC   ±    %    ÷
/// 7    8    9    ×
/// 4    5    6    -
/// 1    2    3    +
/// 0    .    DEL  =
/// ```
///
/// Number keys alternate Dark/Light gray starting with Dark on the 7-8-9 row;
/// operators use their own fixed accent colors.
class CalculatorKeypad extends ConsumerWidget {
  const CalculatorKeypad({super.key});

  CalcKeyRole _numberRole(int row, int col) => (row + col).isEven ? CalcKeyRole.numberDark : CalcKeyRole.numberLight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(calculatorSessionProvider.notifier);

    final rows = <List<CalcKeySpec>>[
      [
        CalcKeySpec(label: 'AC', role: CalcKeyRole.clear, onTap: notifier.clearAll, fontSize: 18),
        CalcKeySpec(label: '±', role: CalcKeyRole.function, onTap: notifier.toggleSign),
        CalcKeySpec(label: '%', role: CalcKeyRole.function, onTap: () => notifier.input('%')),
        CalcKeySpec(label: '÷', role: CalcKeyRole.divide, onTap: () => notifier.input('÷')),
      ],
      [
        CalcKeySpec(label: '7', role: _numberRole(0, 0), onTap: () => notifier.input('7')),
        CalcKeySpec(label: '8', role: _numberRole(0, 1), onTap: () => notifier.input('8')),
        CalcKeySpec(label: '9', role: _numberRole(0, 2), onTap: () => notifier.input('9')),
        CalcKeySpec(label: '×', role: CalcKeyRole.multiply, onTap: () => notifier.input('×')),
      ],
      [
        CalcKeySpec(label: '4', role: _numberRole(1, 0), onTap: () => notifier.input('4')),
        CalcKeySpec(label: '5', role: _numberRole(1, 1), onTap: () => notifier.input('5')),
        CalcKeySpec(label: '6', role: _numberRole(1, 2), onTap: () => notifier.input('6')),
        CalcKeySpec(label: '-', role: CalcKeyRole.subtract, onTap: () => notifier.input('-')),
      ],
      [
        CalcKeySpec(label: '1', role: _numberRole(2, 0), onTap: () => notifier.input('1')),
        CalcKeySpec(label: '2', role: _numberRole(2, 1), onTap: () => notifier.input('2')),
        CalcKeySpec(label: '3', role: _numberRole(2, 2), onTap: () => notifier.input('3')),
        CalcKeySpec(label: '+', role: CalcKeyRole.add, onTap: () => notifier.input('+')),
      ],
      [
        CalcKeySpec(label: '0', role: _numberRole(3, 0), onTap: () => notifier.input('0')),
        CalcKeySpec(label: '.', role: CalcKeyRole.function, onTap: () => notifier.input('.')),
        CalcKeySpec(label: 'DEL', role: CalcKeyRole.delete, onTap: notifier.backspace, fontSize: 15),
        CalcKeySpec(label: '=', role: CalcKeyRole.equals, onTap: notifier.equals),
      ],
    ];

    return CalculatorKeypadGrid(rows: rows);
  }
}