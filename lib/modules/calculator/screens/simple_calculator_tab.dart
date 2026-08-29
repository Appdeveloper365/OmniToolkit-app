/// FILE: lib/modules/calculator/screens/simple_calculator_tab.dart
import 'package:flutter/material.dart';

import '../widgets/calculator_keypad.dart';
import '../widgets/expression_field.dart';

class SimpleCalculatorTab extends StatelessWidget {
  const SimpleCalculatorTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ExpressionField(),
        SizedBox(height: 16),
        CalculatorKeypad(scientific: false),
      ],
    );
  }
}
