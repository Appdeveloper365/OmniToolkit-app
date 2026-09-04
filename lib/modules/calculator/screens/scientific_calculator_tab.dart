/// FILE: lib/modules/calculator/screens/scientific_calculator_tab.dart
import 'package:flutter/material.dart';

import '../widgets/calculator_body.dart';
import '../widgets/calculator_display.dart';
import '../widgets/calculator_keyboard_shortcuts.dart';
import '../widgets/history_panel.dart';
import '../widgets/scientific_keypad.dart';

/// The "Scientific" calculator tab: trig, logs, powers, roots, memory
/// functions, sharing the same premium display and session history as
/// Standard.
class ScientificCalculatorTab extends StatelessWidget {
  const ScientificCalculatorTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const CalculatorKeyboardShortcuts(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: CalculatorBody(
          maxWidth: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CalculatorDisplay(),
              HistoryPanel(),
              SizedBox(height: 16),
              ScientificKeypad(),
            ],
          ),
        ),
      ),
    );
  }
}