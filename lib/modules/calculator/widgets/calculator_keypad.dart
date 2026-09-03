import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/calculator_provider.dart';

/// Button keypad that appends tokens into the shared editable expression
/// field. [scientific] adds an extra row of scientific functions.
class CalculatorKeypad extends ConsumerWidget {
  const CalculatorKeypad({super.key, this.scientific = false});

  final bool scientific;

  static const _basicKeys = [
    ['7', '8', '9', '÷'],
    ['4', '5', '6', '×'],
    ['1', '2', '3', '-'],
    ['0', '.', '=', '+'],
  ];

  static const _scientificKeys = [
    ['sin(', 'cos(', 'tan(', '('],
    ['log(', 'ln(', 'sqrt(', ')'],
    ['^', 'π', '%', 'C'],
  ];

  void _onKeyTap(WidgetRef ref, String key) {
    final current = ref.read(expressionInputProvider);
    if (key == 'C') {
      ref.read(expressionInputProvider.notifier).state = '';
      return;
    }
    if (key == '=') {
      final result = ref.read(expressionResultProvider);
      if (result.isNotEmpty && result != 'Error') {
        ref.read(expressionInputProvider.notifier).state = result;
      }
      return;
    }
    ref.read(expressionInputProvider.notifier).state = current + key;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = [
      if (scientific) ..._scientificKeys,
      ..._basicKeys,
    ];
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                for (final key in row)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilledButton.tonal(
                        onPressed: () => _onKeyTap(ref, key),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: Text(key, style: const TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final current = ref.read(expressionInputProvider);
                if (current.isEmpty) return;
                ref.read(expressionInputProvider.notifier).state =
                    current.substring(0, current.length - 1);
              },
              icon: const Icon(Icons.backspace_outlined),
              label: const Text('Backspace'),
            ),
          ),
        ),
      ],
    );
  }
}
