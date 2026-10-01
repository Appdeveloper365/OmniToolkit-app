/// FILE: test/standard_keypad_verification_test.dart
///
/// Generated check of the Standard calculator keypad. Expected values come
/// from an independent reference model, so an error in the app cannot be
/// mirrored in the expectation. Complements the scientific suite, which
/// exercises the same notifier through a different set of keys.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/modules/calculator/providers/calculator_provider.dart';
import 'package:omnitoolkit/modules/calculator/widgets/calculator_keypad.dart';

void main() {
  const surface = Size(800, 1200);
  final keypad = find.byType(CalculatorKeypad);

  Future<void> tapKey(WidgetTester t, String label) async {
    final f = find.descendant(of: keypad, matching: find.text(label));
    expect(f, findsOneWidget, reason: 'key $label is not on the keypad');
    await t.tap(f);
    await t.pump();
  }

  testWidgets('[binary] 7 ÷ 2 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["7", "÷", "2", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "3.5", reason: "binary: 7 ÷ 2 = -> want 3.5");
  });

  testWidgets('[binary] 3 ÷ 4 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["3", "÷", "4", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "0.75", reason: "binary: 3 ÷ 4 = -> want 0.75");
  });

  testWidgets('[binary] 9 ÷ 4 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["9", "÷", "4", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "2.25", reason: "binary: 9 ÷ 4 = -> want 2.25");
  });

  testWidgets('[binary] 2 ÷ 3 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "÷", "3", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "0.6666666667", reason: "binary: 2 ÷ 3 = -> want 0.6666666667");
  });

  testWidgets('[binary] 8 ÷ 6 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["8", "÷", "6", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "1.333333333", reason: "binary: 8 ÷ 6 = -> want 1.333333333");
  });

  testWidgets('[binary] 5 ÷ 5 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["5", "÷", "5", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "1", reason: "binary: 5 ÷ 5 = -> want 1");
  });

  testWidgets('[binary] 0 ÷ 7 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["0", "÷", "7", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "0", reason: "binary: 0 ÷ 7 = -> want 0");
  });

  testWidgets('[binary] 1 ÷ 3 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "÷", "3", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "0.3333333333", reason: "binary: 1 ÷ 3 = -> want 0.3333333333");
  });

  testWidgets('[binary] 0 . 5 ÷ 2 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["0", ".", "5", "÷", "2", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "0.25", reason: "binary: 0 . 5 ÷ 2 = -> want 0.25");
  });

  testWidgets('[binary] 6 ÷ 0 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["6", "÷", "0", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "Error", reason: "binary: 6 ÷ 0 = -> want Error");
  });

  testWidgets('[binary] 1 2 ÷ 7 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "2", "÷", "7", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "1.714285714", reason: "binary: 1 2 ÷ 7 = -> want 1.714285714");
  });

  testWidgets('[binary] 1 0 0 ÷ 7 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "0", "0", "÷", "7", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "14.28571429", reason: "binary: 1 0 0 ÷ 7 = -> want 14.28571429");
  });

  testWidgets('[binary] 7 × 2 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["7", "×", "2", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "14", reason: "binary: 7 × 2 = -> want 14");
  });

  testWidgets('[binary] 3 × 4 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["3", "×", "4", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "12", reason: "binary: 3 × 4 = -> want 12");
  });

  testWidgets('[binary] 9 × 4 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["9", "×", "4", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "36", reason: "binary: 9 × 4 = -> want 36");
  });

  testWidgets('[binary] 2 × 3 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "×", "3", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "6", reason: "binary: 2 × 3 = -> want 6");
  });

  testWidgets('[binary] 8 × 6 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["8", "×", "6", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "48", reason: "binary: 8 × 6 = -> want 48");
  });

  testWidgets('[binary] 5 × 5 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["5", "×", "5", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "25", reason: "binary: 5 × 5 = -> want 25");
  });

  testWidgets('[binary] 0 × 7 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["0", "×", "7", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "0", reason: "binary: 0 × 7 = -> want 0");
  });

  testWidgets('[binary] 1 × 3 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "×", "3", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "3", reason: "binary: 1 × 3 = -> want 3");
  });

  testWidgets('[binary] 0 . 5 × 2 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["0", ".", "5", "×", "2", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "1", reason: "binary: 0 . 5 × 2 = -> want 1");
  });

  testWidgets('[binary] 6 × 0 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["6", "×", "0", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "0", reason: "binary: 6 × 0 = -> want 0");
  });

  testWidgets('[binary] 1 2 × 7 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "2", "×", "7", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "84", reason: "binary: 1 2 × 7 = -> want 84");
  });

  testWidgets('[binary] 1 0 0 × 7 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "0", "0", "×", "7", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "700", reason: "binary: 1 0 0 × 7 = -> want 700");
  });

  testWidgets('[binary] 7 - 2 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["7", "-", "2", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "5", reason: "binary: 7 - 2 = -> want 5");
  });

  testWidgets('[binary] 3 - 4 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["3", "-", "4", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "-1", reason: "binary: 3 - 4 = -> want -1");
  });

  testWidgets('[binary] 9 - 4 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["9", "-", "4", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "5", reason: "binary: 9 - 4 = -> want 5");
  });

  testWidgets('[binary] 2 - 3 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "-", "3", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "-1", reason: "binary: 2 - 3 = -> want -1");
  });

  testWidgets('[binary] 8 - 6 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["8", "-", "6", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "2", reason: "binary: 8 - 6 = -> want 2");
  });

  testWidgets('[binary] 5 - 5 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["5", "-", "5", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "0", reason: "binary: 5 - 5 = -> want 0");
  });

  testWidgets('[binary] 0 - 7 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["0", "-", "7", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "-7", reason: "binary: 0 - 7 = -> want -7");
  });

  testWidgets('[binary] 1 - 3 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "-", "3", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "-2", reason: "binary: 1 - 3 = -> want -2");
  });

  testWidgets('[binary] 0 . 5 - 2 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["0", ".", "5", "-", "2", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "-1.5", reason: "binary: 0 . 5 - 2 = -> want -1.5");
  });

  testWidgets('[binary] 6 - 0 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["6", "-", "0", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "6", reason: "binary: 6 - 0 = -> want 6");
  });

  testWidgets('[binary] 1 2 - 7 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "2", "-", "7", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "5", reason: "binary: 1 2 - 7 = -> want 5");
  });

  testWidgets('[binary] 1 0 0 - 7 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "0", "0", "-", "7", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "93", reason: "binary: 1 0 0 - 7 = -> want 93");
  });

  testWidgets('[binary] 7 + 2 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["7", "+", "2", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "9", reason: "binary: 7 + 2 = -> want 9");
  });

  testWidgets('[binary] 3 + 4 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["3", "+", "4", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "7", reason: "binary: 3 + 4 = -> want 7");
  });

  testWidgets('[binary] 9 + 4 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["9", "+", "4", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "13", reason: "binary: 9 + 4 = -> want 13");
  });

  testWidgets('[binary] 2 + 3 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "+", "3", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "5", reason: "binary: 2 + 3 = -> want 5");
  });

  testWidgets('[binary] 8 + 6 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["8", "+", "6", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "14", reason: "binary: 8 + 6 = -> want 14");
  });

  testWidgets('[binary] 5 + 5 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["5", "+", "5", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "10", reason: "binary: 5 + 5 = -> want 10");
  });

  testWidgets('[binary] 0 + 7 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["0", "+", "7", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "7", reason: "binary: 0 + 7 = -> want 7");
  });

  testWidgets('[binary] 1 + 3 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "+", "3", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "4", reason: "binary: 1 + 3 = -> want 4");
  });

  testWidgets('[binary] 0 . 5 + 2 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["0", ".", "5", "+", "2", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "2.5", reason: "binary: 0 . 5 + 2 = -> want 2.5");
  });

  testWidgets('[binary] 6 + 0 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["6", "+", "0", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "6", reason: "binary: 6 + 0 = -> want 6");
  });

  testWidgets('[binary] 1 2 + 7 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "2", "+", "7", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "19", reason: "binary: 1 2 + 7 = -> want 19");
  });

  testWidgets('[binary] 1 0 0 + 7 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "0", "0", "+", "7", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "107", reason: "binary: 1 0 0 + 7 = -> want 107");
  });

  testWidgets('[live] 7 ÷ 2', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["7", "÷", "2"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "3.5", reason: "live: 7 ÷ 2 -> want 3.5");
  });

  testWidgets('[live] 3 ÷ 4', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["3", "÷", "4"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "0.75", reason: "live: 3 ÷ 4 -> want 0.75");
  });

  testWidgets('[live] 9 ÷ 4', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["9", "÷", "4"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "2.25", reason: "live: 9 ÷ 4 -> want 2.25");
  });

  testWidgets('[live] 2 ÷ 3', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "÷", "3"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "0.6666666667", reason: "live: 2 ÷ 3 -> want 0.6666666667");
  });

  testWidgets('[live] 8 ÷ 6', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["8", "÷", "6"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "1.333333333", reason: "live: 8 ÷ 6 -> want 1.333333333");
  });

  testWidgets('[live] 5 ÷ 5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["5", "÷", "5"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "1", reason: "live: 5 ÷ 5 -> want 1");
  });

  testWidgets('[live] 7 × 2', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["7", "×", "2"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "14", reason: "live: 7 × 2 -> want 14");
  });

  testWidgets('[live] 3 × 4', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["3", "×", "4"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "12", reason: "live: 3 × 4 -> want 12");
  });

  testWidgets('[live] 9 × 4', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["9", "×", "4"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "36", reason: "live: 9 × 4 -> want 36");
  });

  testWidgets('[live] 2 × 3', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "×", "3"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "6", reason: "live: 2 × 3 -> want 6");
  });

  testWidgets('[live] 8 × 6', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["8", "×", "6"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "48", reason: "live: 8 × 6 -> want 48");
  });

  testWidgets('[live] 5 × 5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["5", "×", "5"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "25", reason: "live: 5 × 5 -> want 25");
  });

  testWidgets('[live] 7 - 2', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["7", "-", "2"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "5", reason: "live: 7 - 2 -> want 5");
  });

  testWidgets('[live] 3 - 4', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["3", "-", "4"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "-1", reason: "live: 3 - 4 -> want -1");
  });

  testWidgets('[live] 9 - 4', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["9", "-", "4"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "5", reason: "live: 9 - 4 -> want 5");
  });

  testWidgets('[live] 2 - 3', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "-", "3"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "-1", reason: "live: 2 - 3 -> want -1");
  });

  testWidgets('[live] 8 - 6', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["8", "-", "6"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "2", reason: "live: 8 - 6 -> want 2");
  });

  testWidgets('[live] 5 - 5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["5", "-", "5"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "0", reason: "live: 5 - 5 -> want 0");
  });

  testWidgets('[live] 7 + 2', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["7", "+", "2"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "9", reason: "live: 7 + 2 -> want 9");
  });

  testWidgets('[live] 3 + 4', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["3", "+", "4"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "7", reason: "live: 3 + 4 -> want 7");
  });

  testWidgets('[live] 9 + 4', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["9", "+", "4"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "13", reason: "live: 9 + 4 -> want 13");
  });

  testWidgets('[live] 2 + 3', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "+", "3"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "5", reason: "live: 2 + 3 -> want 5");
  });

  testWidgets('[live] 8 + 6', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["8", "+", "6"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "14", reason: "live: 8 + 6 -> want 14");
  });

  testWidgets('[live] 5 + 5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["5", "+", "5"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "10", reason: "live: 5 + 5 -> want 10");
  });

  testWidgets('[chain] 2 + 3 × 4 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "+", "3", "×", "4", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "14", reason: "chain: 2 + 3 × 4 = -> want 14");
  });

  testWidgets('[chain] 2 × 3 + 4 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "×", "3", "+", "4", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "10", reason: "chain: 2 × 3 + 4 = -> want 10");
  });

  testWidgets('[chain] 2 + 3 + 4 + 5 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "+", "3", "+", "4", "+", "5", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "14", reason: "chain: 2 + 3 + 4 + 5 = -> want 14");
  });

  testWidgets('[chain] 2 × 3 × 4 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "×", "3", "×", "4", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "24", reason: "chain: 2 × 3 × 4 = -> want 24");
  });

  testWidgets('[chain] 1 0 0 ÷ 4 ÷ 5 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "0", "0", "÷", "4", "÷", "5", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "5", reason: "chain: 1 0 0 ÷ 4 ÷ 5 = -> want 5");
  });

  testWidgets('[chain] 9 - 3 - 2 - 1 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["9", "-", "3", "-", "2", "-", "1", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "3", reason: "chain: 9 - 3 - 2 - 1 = -> want 3");
  });

  testWidgets('[chain] 2 + 3 × 4 - 6 ÷ 2 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "+", "3", "×", "4", "-", "6", "÷", "2", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "11", reason: "chain: 2 + 3 × 4 - 6 ÷ 2 = -> want 11");
  });

  testWidgets('[chain] 1 0 + 2 0 × 3 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "0", "+", "2", "0", "×", "3", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "70", reason: "chain: 1 0 + 2 0 × 3 = -> want 70");
  });

  testWidgets('[chain] 7 ÷ 2 + 1 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["7", "÷", "2", "+", "1", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "4.5", reason: "chain: 7 ÷ 2 + 1 = -> want 4.5");
  });

  testWidgets('[chain] 1 2 × 1 2 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "2", "×", "1", "2", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "144", reason: "chain: 1 2 × 1 2 = -> want 144");
  });

  testWidgets('[chain] 1 - 2 - 3 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "-", "2", "-", "3", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "-4", reason: "chain: 1 - 2 - 3 = -> want -4");
  });

  testWidgets('[chain] 1 0 0 - 5 0 - 2 5 + 1 0 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "0", "0", "-", "5", "0", "-", "2", "5", "+", "1", "0", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "35", reason: "chain: 1 0 0 - 5 0 - 2 5 + 1 0 = -> want 35");
  });

  testWidgets('[float] 0 . 1 + 0 . 2 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["0", ".", "1", "+", "0", ".", "2", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "0.3", reason: "float: 0 . 1 + 0 . 2 = -> want 0.3");
  });

  testWidgets('[float] 1 ÷ 3 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "÷", "3", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "0.3333333333", reason: "float: 1 ÷ 3 = -> want 0.3333333333");
  });

  testWidgets('[float] 2 ÷ 3 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "÷", "3", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "0.6666666667", reason: "float: 2 ÷ 3 = -> want 0.6666666667");
  });

  testWidgets('[float] 1 0 ÷ 3 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "0", "÷", "3", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "3.333333333", reason: "float: 1 0 ÷ 3 = -> want 3.333333333");
  });

  testWidgets('[float] 0 . 0 1 × 0 . 0 1 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["0", ".", "0", "1", "×", "0", ".", "0", "1", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "0.0001", reason: "float: 0 . 0 1 × 0 . 0 1 = -> want 0.0001");
  });

  testWidgets('[float] 1 . 5 × 2 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", ".", "5", "×", "2", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "3", reason: "float: 1 . 5 × 2 = -> want 3");
  });

  testWidgets('[float] 1 2 5 0 0 0 0 0 0 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "2", "5", "0", "0", "0", "0", "0", "0", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "125000000", reason: "float: 1 2 5 0 0 0 0 0 0 = -> want 125000000");
  });

  testWidgets('[sign] 5 ±', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["5", "±"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.expression, "-5", reason: "sign: 5 ± -> want -5");
  });

  testWidgets('[sign] 5 ± ±', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["5", "±", "±"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.expression, "5", reason: "sign: 5 ± ± -> want 5");
  });

  testWidgets('[sign] 2 + 3 ±', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "+", "3", "±"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.expression, "2+-3", reason: "sign: 2 + 3 ± -> want 2+-3");
  });

  testWidgets('[sign] 2 - 3 ±', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "-", "3", "±"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.expression, "2--3", reason: "sign: 2 - 3 ± -> want 2--3");
  });

  testWidgets('[sign] 1 2 + 4 5 ±', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "2", "+", "4", "5", "±"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.expression, "12+-45", reason: "sign: 1 2 + 4 5 ± -> want 12+-45");
  });

  testWidgets('[sign] 0 . 5 ±', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["0", ".", "5", "±"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.expression, "-0.5", reason: "sign: 0 . 5 ± -> want -0.5");
  });

  testWidgets('[sign] 0 . 5 ± ±', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["0", ".", "5", "±", "±"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.expression, "0.5", reason: "sign: 0 . 5 ± ± -> want 0.5");
  });

  testWidgets('[sign] 5 ± =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["5", "±", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "-5", reason: "sign: 5 ± = -> want -5");
  });

  testWidgets('[sign] 7 ± × 2 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["7", "±", "×", "2", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "-14", reason: "sign: 7 ± × 2 = -> want -14");
  });

  testWidgets('[sign] 1 2 3 ±', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "2", "3", "±"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "-123", reason: "sign: 1 2 3 ± -> want -123");
  });

  testWidgets('[pct] 5 0 % =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["5", "0", "%", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "0.5", reason: "pct: 5 0 % = -> want 0.5");
  });

  testWidgets('[pct] 2 0 0 % =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "0", "0", "%", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "2", reason: "pct: 2 0 0 % = -> want 2");
  });

  testWidgets('[pct] 1 0 0 0 % =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "0", "0", "0", "%", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "10", reason: "pct: 1 0 0 0 % = -> want 10");
  });

  testWidgets('[pct] 2 0 0 + 1 0 % =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "0", "0", "+", "1", "0", "%", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "200.1", reason: "pct: 2 0 0 + 1 0 % = -> want 200.1");
  });

  testWidgets('[pct] 8 0 0 - 1 0 % =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["8", "0", "0", "-", "1", "0", "%", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "799.9", reason: "pct: 8 0 0 - 1 0 % = -> want 799.9");
  });

  testWidgets('[del] 7 8 DEL', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["7", "8", "DEL"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.expression, "7", reason: "del: 7 8 DEL -> want 7");
  });

  testWidgets('[del] 7 8 DEL DEL', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["7", "8", "DEL", "DEL"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.expression, "", reason: "del: 7 8 DEL DEL -> want ");
  });

  testWidgets('[del] 1 2 + 3 DEL', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "2", "+", "3", "DEL"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.expression, "12+", reason: "del: 1 2 + 3 DEL -> want 12+");
  });

  testWidgets('[del] 1 2 + 3 DEL DEL DEL', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "2", "+", "3", "DEL", "DEL", "DEL"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.expression, "1", reason: "del: 1 2 + 3 DEL DEL DEL -> want 1");
  });

  testWidgets('[del] 1 2 + 3 = DEL', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "2", "+", "3", "=", "DEL"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.expression, "1", reason: "del: 1 2 + 3 = DEL -> want 1");
  });

  testWidgets('[ac] 9 9 AC', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["9", "9", "AC"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.expression, "", reason: "ac: 9 9 AC -> want ");
  });

  testWidgets('[ac] 5 + 5 = AC', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["5", "+", "5", "=", "AC"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.expression, "", reason: "ac: 5 + 5 = AC -> want ");
  });

  testWidgets('[ac] AC', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["AC"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.expression, "", reason: "ac: AC -> want ");
  });

  testWidgets('[chain2] 2 + 3 = + 4 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "+", "3", "=", "+", "4", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "9", reason: "chain2: 2 + 3 = + 4 = -> want 9");
  });

  testWidgets('[chain2] 2 + 3 = 9', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "+", "3", "=", "9"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.expression, "9", reason: "chain2: 2 + 3 = 9 -> want 9");
  });

  testWidgets('[chain2] 2 + 3 = × 4 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "+", "3", "=", "×", "4", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "20", reason: "chain2: 2 + 3 = × 4 = -> want 20");
  });

  testWidgets('[chain2] 6 ÷ 2 = + 1 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["6", "÷", "2", "=", "+", "1", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "4", reason: "chain2: 6 ÷ 2 = + 1 = -> want 4");
  });

  testWidgets('[chain2] 2 + 3 = .', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "+", "3", "=", "."]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.expression, ".", reason: "chain2: 2 + 3 = . -> want .");
  });

  testWidgets('[chain2] 2 + 3 = 0 0 + 1 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "+", "3", "=", "0", "0", "+", "1", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "1", reason: "chain2: 2 + 3 = 0 0 + 1 = -> want 1");
  });

  testWidgets('[chain2] 2 + 3 = - 1 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["2", "+", "3", "=", "-", "1", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "4", reason: "chain2: 2 + 3 = - 1 = -> want 4");
  });

  testWidgets('[chain2] 9 × 9 = + 9 = + 9 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["9", "×", "9", "=", "+", "9", "=", "+", "9", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "99", reason: "chain2: 9 × 9 = + 9 = + 9 = -> want 99");
  });

  testWidgets('[dot] 0 . 5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["0", ".", "5"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "0.5", reason: "dot: 0 . 5 -> want 0.5");
  });

  testWidgets('[dot] . 5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in [".", "5"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "0.5", reason: "dot: . 5 -> want 0.5");
  });

  testWidgets('[dot] 1 . 2 × 2 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", ".", "2", "×", "2", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "2.4", reason: "dot: 1 . 2 × 2 = -> want 2.4");
  });

  testWidgets('[dot] 1 2 . 3 4 + 0 . 0 6 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "2", ".", "3", "4", "+", "0", ".", "0", "6", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "12.4", reason: "dot: 1 2 . 3 4 + 0 . 0 6 = -> want 12.4");
  });

  testWidgets('[err] 5 ÷ 0 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["5", "÷", "0", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "Error", reason: "err: 5 ÷ 0 = -> want Error");
  });

  testWidgets('[err] 0 ÷ 0 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["0", "÷", "0", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "Error", reason: "err: 0 ÷ 0 = -> want Error");
  });

  testWidgets('[err] 0 ÷ 5 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["0", "÷", "5", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "0", reason: "err: 0 ÷ 5 = -> want 0");
  });

  testWidgets('[err] 1 + =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "+", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "", reason: "err: 1 + = -> want ");
  });

  testWidgets('[err] = =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["=", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "", reason: "err: = = -> want ");
  });

  testWidgets('[err] × 2 + 3 =', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["×", "2", "+", "3", "="]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "Error", reason: "err: × 2 + 3 = -> want Error");
  });

  testWidgets('[err] 1 +', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["1", "+"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "", reason: "err: 1 + -> want ");
  });

  testWidgets('[err] DEL', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["DEL"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "", reason: "err: DEL -> want ");
  });

  testWidgets('[err] AC', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: CalculatorKeypad())),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final k in ["AC"]) { await tapKey(t, k); }
    final s = c.read(calculatorSessionProvider);
    expect(s.result, "", reason: "err: AC -> want ");
  });

}
