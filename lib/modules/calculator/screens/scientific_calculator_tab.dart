/// FILE: lib/modules/calculator/screens/scientific_calculator_tab.dart
import 'package:flutter/material.dart';

import '../widgets/calculator_keypad.dart';
import '../widgets/expression_field.dart';

class ScientificCalculatorTab extends StatelessWidget {
  const ScientificCalculatorTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ExpressionField(),
        SizedBox(height: 16),
        CalculatorKeypad(scientific: true),
      ],
    );
  }
}
