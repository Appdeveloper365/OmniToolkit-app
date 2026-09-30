/// FILE: test/scientific_keypad_functional_test.dart
///
/// Exercises every key on the scientific keypad by tapping it and asserting
/// the resulting calculator state. The existing widget tests only cover a
/// handful of keys, so a reflow of the grid could silently break a callback
/// without any test failing. This file taps all 44 and checks the arithmetic.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/modules/calculator/providers/calculator_provider.dart';
import 'package:omnitoolkit/modules/calculator/services/expression_service.dart';
import 'package:omnitoolkit/modules/calculator/widgets/premium_calculator_button.dart';
import 'package:omnitoolkit/modules/calculator/widgets/scientific_keypad.dart';

void main() {
  // Big surface so all 8 rows are laid out and tappable without scrolling.
  const surface = Size(800, 1400);
  final keypad = find.byType(ScientificKeypad);

  /// Taps the key with [label], scoped to the keypad so digit labels that also
  /// appear in the display are not ambiguous.
  Future<void> tapKey(WidgetTester t, String label) async {
    final finder = find.descendant(of: keypad, matching: find.text(label));
    expect(finder, findsOneWidget, reason: 'key $label is not on the keypad');
    await t.tap(finder);
    await t.pump();
  }

  /// Taps [keys] in order after an AC, then returns the live result string.
  Future<String> evaluate(WidgetTester t, ProviderContainer c, List<String> keys) async {
    await tapKey(t, 'AC');
    for (final k in keys) {
      await tapKey(t, k);
    }
    return c.read(calculatorSessionProvider).result;
  }

  /// Builds the keypad inside a fresh [ProviderContainer] and runs [body].
  ///
  /// Each scenario is registered as its own testWidgets so a failure names the
  /// behaviour that broke rather than pointing at a shared harness.
  void withKeypad(
    String name,
    Future<void> Function(WidgetTester t, ProviderContainer c) body,
  ) {
    testWidgets(name, (t) async {
      await t.binding.setSurfaceSize(surface);
      addTearDown(() => t.binding.setSurfaceSize(null));
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await t.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(
            home: Scaffold(body: Center(child: ScientificKeypad())),
          ),
        ),
      );
      await t.pumpAndSettle();
      await body(t, c);
    });
  }

  // ---- Scientific functions ------------------------------------------------

  withKeypad('sin/cos/tan run in degrees', (t, c) async {
    expect(await evaluate(t, c, ['3', '0', 'sin']), '0.5'); // sin 30
    expect(await evaluate(t, c, ['6', '0', 'cos']), '0.5'); // cos 60
    expect(await evaluate(t, c, ['4', '5', 'tan']), '1'); // tan 45
  });

  withKeypad('inverse trig returns degrees', (t, c) async {
    expect(await evaluate(t, c, ['0', '.', '5', 'asin']), '30');
    expect(await evaluate(t, c, ['1', 'acos']), '0');
    expect(await evaluate(t, c, ['1', 'atan']), '45');
  });

  withKeypad('log and ln', (t, c) async {
    expect(await evaluate(t, c, ['1', '0', '0', 'log']), '2'); // log10 100
    expect(await evaluate(t, c, ['e', 'ln']), '1');
  });

  withKeypad('roots and powers', (t, c) async {
    expect(await evaluate(t, c, ['9', '√']), '3');
    expect(await evaluate(t, c, ['5', 'x²']), '25');
    expect(await evaluate(t, c, ['2', 'x³']), '8');
    expect(await evaluate(t, c, ['4', '1/x']), '0.25');
    // The nth-root key injects "^(1/" and leaves the bracket to be
    // auto-closed at evaluation time.
    expect(await evaluate(t, c, ['1', '6', 'ⁿ√', '2']), '4'); // 16^(1/2)
    expect(await evaluate(t, c, ['2', '7', 'ⁿ√', '3']), '3'); // 27^(1/3)
    expect(await evaluate(t, c, ['2', 'xʸ', '3', '=']), '8');
  });

  withKeypad('factorial, absolute value, pi, e', (t, c) async {
    expect(await evaluate(t, c, ['5', 'x!']), '120');
    expect(await evaluate(t, c, ['5', '±', '|x|']), '5'); // |-5| = 5
    expect(await evaluate(t, c, ['π', 'x²']), '9.869604401');
    expect(await evaluate(t, c, ['e']), '2.718281828');
  });

  // ---- Operators (right-hand column) --------------------------------------

  withKeypad('arithmetic operators in the right column all work', (t, c) async {
    expect(await evaluate(t, c, ['7', '÷', '2', '=']), '3.5');
    expect(await evaluate(t, c, ['3', '×', '4', '=']), '12');
    expect(await evaluate(t, c, ['9', '-', '4', '=']), '5');
    expect(await evaluate(t, c, ['2', '+', '3', '=']), '5');
  });

  withKeypad('parentheses and percent', (t, c) async {
    expect(await evaluate(t, c, ['2', '×', '(', '1', '+', '2', ')', '=']), '6');
    expect(await evaluate(t, c, ['1', '0', '÷', '3', '%', '=']), '0.03333333333');
  });

  withKeypad('sign toggle and decimal point', (t, c) async {
    expect(await evaluate(t, c, ['5', '±']), '-5');
    expect(await evaluate(t, c, ['5', '±', '±']), '5');
    expect(await evaluate(t, c, ['0', '.', '5']), '0.5');
  });

  withKeypad('DEL removes one character', (t, c) async {
    await evaluate(t, c, ['7', '8']);
    expect(c.read(calculatorSessionProvider).expression, '78');
    await tapKey(t, 'DEL');
    expect(c.read(calculatorSessionProvider).expression, '7');
  });

  // ---- Memory keys --------------------------------------------------------

  withKeypad('MC/MR/M+/M- on one row work and survive AC', (t, c) async {
    // 5 M+ stores 5.
    await tapKey(t, 'AC');
    await tapKey(t, '5');
    await tapKey(t, 'M+');
    expect(c.read(calculatorSessionProvider).memory, 5.0);

    // AC clears the expression but must NOT clear memory (hardware rule).
    await tapKey(t, 'AC');
    expect(c.read(calculatorSessionProvider).memory, 5.0);
    expect(c.read(calculatorSessionProvider).expression, '');

    // MR recalls 5.
    await tapKey(t, 'MR');
    expect(c.read(calculatorSessionProvider).expression, '5');

    // M+ then M- net back to 5.
    await tapKey(t, 'M+');
    expect(c.read(calculatorSessionProvider).memory, 10.0);
    await tapKey(t, 'M-');
    expect(c.read(calculatorSessionProvider).memory, 5.0);

    // MC clears the register; MR then recalls nothing.
    await tapKey(t, 'MC');
    expect(c.read(calculatorSessionProvider).memory, 0.0);
    expect(c.read(calculatorSessionProvider).hasMemory, isFalse);
  });

  // ---- Top row ------------------------------------------------------------

  withKeypad('AC clears and = evaluates', (t, c) async {
    // = evaluates the pending expression.
    await evaluate(t, c, ['2', '+', '3']);
    await tapKey(t, '=');
    expect(c.read(calculatorSessionProvider).expression, '5');

    // AC resets the display to empty/zero.
    await tapKey(t, 'AC');
    expect(c.read(calculatorSessionProvider).expression, '');
    expect(c.read(calculatorSessionProvider).result, '');
  });

  // ---- Every key is wired and mutates state -------------------------------

  withKeypad('all 44 keys are tappable and each changes calculator state',
      (t, c) async {
    final n = c.read(calculatorSessionProvider.notifier);
    final buttons = find.byType(PremiumCalculatorButton);
    expect(buttons.evaluate().length, 44, reason: 'expected 44 keys');

    /// Seeds a baseline that is deliberately NOT already the answer, so a key
    /// whose correct output would coincide with the input is still detected
    /// as live.
    ///
    /// "12+4" is a complete, evaluable expression that no key leaves unchanged:
    /// `=` yields 16, the unary functions map 16 to something new, `±` flips
    /// the trailing 4, M+/M- add 16 to a preloaded register, MR recalls 4 and
    /// MC zeroes it, and every digit/operator/bracket key extends the text.
    /// A bare digit would be a bad seed, since `=` on "1" yields "1".
    void seed() {
      n.clearAll();
      n.memoryClear();
      n.input('4');
      n.memoryAdd(); // register = 4
      n.clearAll();
      n.input('12');
      n.input('+');
      n.input('4');
    }

    String snapshot() {
      final s = c.read(calculatorSessionProvider);
      return '${s.expression}|${s.result}|${s.memory}|${s.hasMemory}';
    }

    final deadKeys = <String>[];
    for (var i = 0; i < 44; i++) {
      seed();
      final before = snapshot();

      final label = t
          .widget<Text>(
            find.descendant(of: buttons.at(i), matching: find.byType(Text)).first,
          )
          .data!;
      await tapKey(t, label);
      if (snapshot() == before) deadKeys.add(label);
    }

    expect(deadKeys, isEmpty,
        reason: 'these keys changed nothing when tapped: $deadKeys');
  });

  // ---- Service-level regression for the nth-root auto-close ---------------

  test('unclosed parentheses are auto-closed; stray ones ignored', () {
    final service = ExpressionService();
    // The nth-root key leaves the expression mid-bracket; once an exponent has
    // been typed the closing bracket is supplied for the user.
    expect(service.evaluate('16^(1/2'), 4.0);
    expect(service.evaluate('(2+3'), 5.0);
    // A dangling ')' with nothing open is dropped rather than throwing.
    expect(service.evaluate('2+3)'), 5.0);
    // Still an error when the bracket is genuinely incomplete.
    expect(() => service.evaluate('16^(1/'), throwsFormatException);
  });
}
