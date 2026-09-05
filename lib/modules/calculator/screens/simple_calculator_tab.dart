/// FILE: lib/modules/calculator/screens/simple_calculator_tab.dart
import 'package:flutter/material.dart';

import '../widgets/calculator_body.dart';
import '../widgets/calculator_display.dart';
import '../widgets/calculator_keyboard_shortcuts.dart';
import '../widgets/calculator_keypad.dart';

/// The "Standard" calculator tab: compact display with in-display history toggle,
/// and keypad designed to fit within initial mobile viewport without vertical scrolling.
class SimpleCalculatorTab extends StatelessWidget {
  const SimpleCalculatorTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const CalculatorKeyboardShortcuts(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(6),
          child: CalculatorBody(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CalculatorDisplay(),
                SizedBox(height: 6),
                CalculatorKeypad(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
