/// FILE: lib/modules/calculator/screens/simple_calculator_tab.dart
import 'package:flutter/material.dart';

import '../widgets/calculator_body.dart';
import '../widgets/calculator_display.dart';
import '../widgets/calculator_keyboard_shortcuts.dart';
import '../widgets/calculator_keypad.dart';
import '../widgets/history_panel.dart';

/// The "Standard" calculator tab: premium square keypad with +, -, ×, ÷, %,
/// sign toggle, decimal support, session history, and full keyboard support.
class SimpleCalculatorTab extends StatelessWidget {
  const SimpleCalculatorTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const CalculatorKeyboardShortcuts(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: CalculatorBody(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CalculatorDisplay(),
              HistoryPanel(),
              SizedBox(height: 16),
              CalculatorKeypad(),
            ],
          ),
        ),
      ),
    );
  }
}