/// FILE: lib/modules/calculator/widgets/calculator_keyboard_shortcuts.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/calculator_provider.dart';

/// Wraps a calculator tab with physical-keyboard support:
/// Enter = equals, Backspace = delete, Escape = AC, plus digits/operators
/// for full keyboard accessibility alongside touch and mouse.
class CalculatorKeyboardShortcuts extends ConsumerWidget {
  const CalculatorKeyboardShortcuts({super.key, required this.child});

  final Widget child;

  static final _tokenKeys = {
    LogicalKeyboardKey.digit0: '0',
    LogicalKeyboardKey.digit1: '1',
    LogicalKeyboardKey.digit2: '2',
    LogicalKeyboardKey.digit3: '3',
    LogicalKeyboardKey.digit4: '4',
    LogicalKeyboardKey.digit5: '5',
    LogicalKeyboardKey.digit6: '6',
    LogicalKeyboardKey.digit7: '7',
    LogicalKeyboardKey.digit8: '8',
    LogicalKeyboardKey.digit9: '9',
    LogicalKeyboardKey.numpad0: '0',
    LogicalKeyboardKey.numpad1: '1',
    LogicalKeyboardKey.numpad2: '2',
    LogicalKeyboardKey.numpad3: '3',
    LogicalKeyboardKey.numpad4: '4',
    LogicalKeyboardKey.numpad5: '5',
    LogicalKeyboardKey.numpad6: '6',
    LogicalKeyboardKey.numpad7: '7',
    LogicalKeyboardKey.numpad8: '8',
    LogicalKeyboardKey.numpad9: '9',
    LogicalKeyboardKey.period: '.',
    LogicalKeyboardKey.numpadDecimal: '.',
    LogicalKeyboardKey.add: '+',
    LogicalKeyboardKey.numpadAdd: '+',
    LogicalKeyboardKey.minus: '-',
    LogicalKeyboardKey.numpadSubtract: '-',
    LogicalKeyboardKey.slash: '÷',
    LogicalKeyboardKey.numpadDivide: '÷',
    LogicalKeyboardKey.asterisk: '×',
    LogicalKeyboardKey.numpadMultiply: '×',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(calculatorSessionProvider.notifier);

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        final key = event.logicalKey;
        if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
          notifier.equals();
          return KeyEventResult.handled;
        }
        if (key == LogicalKeyboardKey.backspace) {
          notifier.backspace();
          return KeyEventResult.handled;
        }
        if (key == LogicalKeyboardKey.escape) {
          notifier.clearAll();
          return KeyEventResult.handled;
        }
        final token = _tokenKeys[key];
        if (token != null) {
          notifier.input(token);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}