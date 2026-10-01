/// FILE: test/scientific_keypad_verification_test.dart
///
/// Exhaustive generated check of every scientific keypad key. Expected values
/// are computed by an independent reference model rather than hand-written,
/// so an error in the app cannot be mirrored in the expectation.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/modules/calculator/providers/calculator_provider.dart';
import 'package:omnitoolkit/modules/calculator/widgets/scientific_keypad.dart';

void main() {
  const surface = Size(800, 1600);
  final keypad = find.byType(ScientificKeypad);

  Future<void> tapKey(WidgetTester t, String label) async {
    final f = find.descendant(of: keypad, matching: find.text(label));
    expect(f, findsOneWidget, reason: 'key $label is not on the keypad');
    await t.tap(f);
    await t.pump();
  }

  Future<void> run(WidgetTester t, ProviderContainer c,
      List<String> keys, String expected, String group) async {
    await tapKey(t, 'AC');
    for (final k in keys) {
      await tapKey(t, k);
    }
    final s = c.read(calculatorSessionProvider);
    final field = group == 'expr' ? s.expression : s.result;
    expect(field, expected,
        reason: '$group: $keys -> got "$field" '
            '(expr "${s.expression}", res "${s.result}"), expected "$expected"');
  }

  testWidgets('[unary] 0 sin = 0', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", "sin"], "0", "unary");
  });

  testWidgets('[unary] 1 sin = 0.01745240644', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "sin"], "0.01745240644", "unary");
  });

  testWidgets('[unary] 2 sin = 0.0348994967', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "sin"], "0.0348994967", "unary");
  });

  testWidgets('[unary] 5 sin = 0.08715574275', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "sin"], "0.08715574275", "unary");
  });

  testWidgets('[unary] 7 sin = 0.1218693434', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "sin"], "0.1218693434", "unary");
  });

  testWidgets('[unary] 0 . 5 sin = 0.008726535498', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "sin"], "0.008726535498", "unary");
  });

  testWidgets('[unary] 1 . 5 sin = 0.02617694831', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", ".", "5", "sin"], "0.02617694831", "unary");
  });

  testWidgets('[unary] 9 sin = 0.156434465', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["9", "sin"], "0.156434465", "unary");
  });

  testWidgets('[unary] 1 2 sin = 0.2079116908', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "sin"], "0.2079116908", "unary");
  });

  testWidgets('[unary] 0 . 2 5 sin = 0.004363309285', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "2", "5", "sin"], "0.004363309285", "unary");
  });

  testWidgets('[unary] 1 0 0 sin = 0.984807753', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "sin"], "0.984807753", "unary");
  });

  testWidgets('[unary] 0 . 1 sin = 0.001745328366', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "1", "sin"], "0.001745328366", "unary");
  });

  testWidgets('[unary] 0 cos = 1', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", "cos"], "1", "unary");
  });

  testWidgets('[unary] 1 cos = 0.9998476952', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "cos"], "0.9998476952", "unary");
  });

  testWidgets('[unary] 2 cos = 0.999390827', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "cos"], "0.999390827", "unary");
  });

  testWidgets('[unary] 5 cos = 0.9961946981', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "cos"], "0.9961946981", "unary");
  });

  testWidgets('[unary] 7 cos = 0.9925461516', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "cos"], "0.9925461516", "unary");
  });

  testWidgets('[unary] 0 . 5 cos = 0.9999619231', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "cos"], "0.9999619231", "unary");
  });

  testWidgets('[unary] 1 . 5 cos = 0.999657325', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", ".", "5", "cos"], "0.999657325", "unary");
  });

  testWidgets('[unary] 9 cos = 0.9876883406', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["9", "cos"], "0.9876883406", "unary");
  });

  testWidgets('[unary] 1 2 cos = 0.9781476007', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "cos"], "0.9781476007", "unary");
  });

  testWidgets('[unary] 0 . 2 5 cos = 0.9999904807', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "2", "5", "cos"], "0.9999904807", "unary");
  });

  testWidgets('[unary] 1 0 0 cos = -0.1736481777', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "cos"], "-0.1736481777", "unary");
  });

  testWidgets('[unary] 0 . 1 cos = 0.9999984769', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "1", "cos"], "0.9999984769", "unary");
  });

  testWidgets('[unary] 0 tan = 0', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", "tan"], "0", "unary");
  });

  testWidgets('[unary] 1 tan = 0.01745506493', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "tan"], "0.01745506493", "unary");
  });

  testWidgets('[unary] 2 tan = 0.03492076949', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "tan"], "0.03492076949", "unary");
  });

  testWidgets('[unary] 5 tan = 0.08748866353', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "tan"], "0.08748866353", "unary");
  });

  testWidgets('[unary] 7 tan = 0.1227845609', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "tan"], "0.1227845609", "unary");
  });

  testWidgets('[unary] 0 . 5 tan = 0.008726867791', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "tan"], "0.008726867791", "unary");
  });

  testWidgets('[unary] 1 . 5 tan = 0.02618592157', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", ".", "5", "tan"], "0.02618592157", "unary");
  });

  testWidgets('[unary] 9 tan = 0.1583844403', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["9", "tan"], "0.1583844403", "unary");
  });

  testWidgets('[unary] 1 2 tan = 0.2125565617', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "tan"], "0.2125565617", "unary");
  });

  testWidgets('[unary] 0 . 2 5 tan = 0.004363350821', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "2", "5", "tan"], "0.004363350821", "unary");
  });

  testWidgets('[unary] 1 0 0 tan = -5.67128182', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "tan"], "-5.67128182", "unary");
  });

  testWidgets('[unary] 0 . 1 tan = 0.001745331024', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "1", "tan"], "0.001745331024", "unary");
  });

  testWidgets('[unary] 0 asin = 0', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", "asin"], "0", "unary");
  });

  testWidgets('[unary] 1 asin = 90', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "asin"], "90", "unary");
  });

  testWidgets('[unary] 2 asin = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "asin"], "Error", "unary");
  });

  testWidgets('[unary] 5 asin = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "asin"], "Error", "unary");
  });

  testWidgets('[unary] 7 asin = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "asin"], "Error", "unary");
  });

  testWidgets('[unary] 0 . 5 asin = 30', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "asin"], "30", "unary");
  });

  testWidgets('[unary] 1 . 5 asin = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", ".", "5", "asin"], "Error", "unary");
  });

  testWidgets('[unary] 9 asin = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["9", "asin"], "Error", "unary");
  });

  testWidgets('[unary] 1 2 asin = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "asin"], "Error", "unary");
  });

  testWidgets('[unary] 0 . 2 5 asin = 14.47751219', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "2", "5", "asin"], "14.47751219", "unary");
  });

  testWidgets('[unary] 1 0 0 asin = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "asin"], "Error", "unary");
  });

  testWidgets('[unary] 0 . 1 asin = 5.739170477', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "1", "asin"], "5.739170477", "unary");
  });

  testWidgets('[unary] 0 acos = 90', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", "acos"], "90", "unary");
  });

  testWidgets('[unary] 1 acos = 0', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "acos"], "0", "unary");
  });

  testWidgets('[unary] 2 acos = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "acos"], "Error", "unary");
  });

  testWidgets('[unary] 5 acos = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "acos"], "Error", "unary");
  });

  testWidgets('[unary] 7 acos = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "acos"], "Error", "unary");
  });

  testWidgets('[unary] 0 . 5 acos = 60', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "acos"], "60", "unary");
  });

  testWidgets('[unary] 1 . 5 acos = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", ".", "5", "acos"], "Error", "unary");
  });

  testWidgets('[unary] 9 acos = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["9", "acos"], "Error", "unary");
  });

  testWidgets('[unary] 1 2 acos = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "acos"], "Error", "unary");
  });

  testWidgets('[unary] 0 . 2 5 acos = 75.52248781', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "2", "5", "acos"], "75.52248781", "unary");
  });

  testWidgets('[unary] 1 0 0 acos = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "acos"], "Error", "unary");
  });

  testWidgets('[unary] 0 . 1 acos = 84.26082952', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "1", "acos"], "84.26082952", "unary");
  });

  testWidgets('[unary] 0 atan = 0', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", "atan"], "0", "unary");
  });

  testWidgets('[unary] 1 atan = 45', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "atan"], "45", "unary");
  });

  testWidgets('[unary] 2 atan = 63.43494882', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "atan"], "63.43494882", "unary");
  });

  testWidgets('[unary] 5 atan = 78.69006753', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "atan"], "78.69006753", "unary");
  });

  testWidgets('[unary] 7 atan = 81.86989765', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "atan"], "81.86989765", "unary");
  });

  testWidgets('[unary] 0 . 5 atan = 26.56505118', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "atan"], "26.56505118", "unary");
  });

  testWidgets('[unary] 1 . 5 atan = 56.30993247', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", ".", "5", "atan"], "56.30993247", "unary");
  });

  testWidgets('[unary] 9 atan = 83.65980825', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["9", "atan"], "83.65980825", "unary");
  });

  testWidgets('[unary] 1 2 atan = 85.23635831', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "atan"], "85.23635831", "unary");
  });

  testWidgets('[unary] 0 . 2 5 atan = 14.03624347', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "2", "5", "atan"], "14.03624347", "unary");
  });

  testWidgets('[unary] 1 0 0 atan = 89.4270613', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "atan"], "89.4270613", "unary");
  });

  testWidgets('[unary] 0 . 1 atan = 5.710593137', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "1", "atan"], "5.710593137", "unary");
  });

  testWidgets('[unary] 0 log = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", "log"], "Error", "unary");
  });

  testWidgets('[unary] 1 log = 0', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "log"], "0", "unary");
  });

  testWidgets('[unary] 2 log = 0.3010299957', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "log"], "0.3010299957", "unary");
  });

  testWidgets('[unary] 5 log = 0.6989700043', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "log"], "0.6989700043", "unary");
  });

  testWidgets('[unary] 7 log = 0.84509804', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "log"], "0.84509804", "unary");
  });

  testWidgets('[unary] 0 . 5 log = -0.3010299957', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "log"], "-0.3010299957", "unary");
  });

  testWidgets('[unary] 1 . 5 log = 0.1760912591', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", ".", "5", "log"], "0.1760912591", "unary");
  });

  testWidgets('[unary] 9 log = 0.9542425094', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["9", "log"], "0.9542425094", "unary");
  });

  testWidgets('[unary] 1 2 log = 1.079181246', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "log"], "1.079181246", "unary");
  });

  testWidgets('[unary] 0 . 2 5 log = -0.6020599913', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "2", "5", "log"], "-0.6020599913", "unary");
  });

  testWidgets('[unary] 1 0 0 log = 2', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "log"], "2", "unary");
  });

  testWidgets('[unary] 0 . 1 log = -1', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "1", "log"], "-1", "unary");
  });

  testWidgets('[unary] 0 ln = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", "ln"], "Error", "unary");
  });

  testWidgets('[unary] 1 ln = 0', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "ln"], "0", "unary");
  });

  testWidgets('[unary] 2 ln = 0.6931471806', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "ln"], "0.6931471806", "unary");
  });

  testWidgets('[unary] 5 ln = 1.609437912', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "ln"], "1.609437912", "unary");
  });

  testWidgets('[unary] 7 ln = 1.945910149', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "ln"], "1.945910149", "unary");
  });

  testWidgets('[unary] 0 . 5 ln = -0.6931471806', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "ln"], "-0.6931471806", "unary");
  });

  testWidgets('[unary] 1 . 5 ln = 0.4054651081', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", ".", "5", "ln"], "0.4054651081", "unary");
  });

  testWidgets('[unary] 9 ln = 2.197224577', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["9", "ln"], "2.197224577", "unary");
  });

  testWidgets('[unary] 1 2 ln = 2.48490665', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "ln"], "2.48490665", "unary");
  });

  testWidgets('[unary] 0 . 2 5 ln = -1.386294361', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "2", "5", "ln"], "-1.386294361", "unary");
  });

  testWidgets('[unary] 1 0 0 ln = 4.605170186', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "ln"], "4.605170186", "unary");
  });

  testWidgets('[unary] 0 . 1 ln = -2.302585093', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "1", "ln"], "-2.302585093", "unary");
  });

  testWidgets('[unary] 0 √ = 0', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", "√"], "0", "unary");
  });

  testWidgets('[unary] 1 √ = 1', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "√"], "1", "unary");
  });

  testWidgets('[unary] 2 √ = 1.414213562', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "√"], "1.414213562", "unary");
  });

  testWidgets('[unary] 5 √ = 2.236067977', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "√"], "2.236067977", "unary");
  });

  testWidgets('[unary] 7 √ = 2.645751311', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "√"], "2.645751311", "unary");
  });

  testWidgets('[unary] 0 . 5 √ = 0.7071067812', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "√"], "0.7071067812", "unary");
  });

  testWidgets('[unary] 1 . 5 √ = 1.224744871', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", ".", "5", "√"], "1.224744871", "unary");
  });

  testWidgets('[unary] 9 √ = 3', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["9", "√"], "3", "unary");
  });

  testWidgets('[unary] 1 2 √ = 3.464101615', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "√"], "3.464101615", "unary");
  });

  testWidgets('[unary] 0 . 2 5 √ = 0.5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "2", "5", "√"], "0.5", "unary");
  });

  testWidgets('[unary] 1 0 0 √ = 10', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "√"], "10", "unary");
  });

  testWidgets('[unary] 0 . 1 √ = 0.316227766', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "1", "√"], "0.316227766", "unary");
  });

  testWidgets('[unary] 0 x² = 0', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", "x²"], "0", "unary");
  });

  testWidgets('[unary] 1 x² = 1', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "x²"], "1", "unary");
  });

  testWidgets('[unary] 2 x² = 4', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "x²"], "4", "unary");
  });

  testWidgets('[unary] 5 x² = 25', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "x²"], "25", "unary");
  });

  testWidgets('[unary] 7 x² = 49', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "x²"], "49", "unary");
  });

  testWidgets('[unary] 0 . 5 x² = 0.25', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "x²"], "0.25", "unary");
  });

  testWidgets('[unary] 1 . 5 x² = 2.25', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", ".", "5", "x²"], "2.25", "unary");
  });

  testWidgets('[unary] 9 x² = 81', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["9", "x²"], "81", "unary");
  });

  testWidgets('[unary] 1 2 x² = 144', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "x²"], "144", "unary");
  });

  testWidgets('[unary] 0 . 2 5 x² = 0.0625', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "2", "5", "x²"], "0.0625", "unary");
  });

  testWidgets('[unary] 1 0 0 x² = 10000', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "x²"], "10000", "unary");
  });

  testWidgets('[unary] 0 . 1 x² = 0.01', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "1", "x²"], "0.01", "unary");
  });

  testWidgets('[unary] 0 x³ = 0', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", "x³"], "0", "unary");
  });

  testWidgets('[unary] 1 x³ = 1', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "x³"], "1", "unary");
  });

  testWidgets('[unary] 2 x³ = 8', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "x³"], "8", "unary");
  });

  testWidgets('[unary] 5 x³ = 125', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "x³"], "125", "unary");
  });

  testWidgets('[unary] 7 x³ = 343', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "x³"], "343", "unary");
  });

  testWidgets('[unary] 0 . 5 x³ = 0.125', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "x³"], "0.125", "unary");
  });

  testWidgets('[unary] 1 . 5 x³ = 3.375', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", ".", "5", "x³"], "3.375", "unary");
  });

  testWidgets('[unary] 9 x³ = 729', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["9", "x³"], "729", "unary");
  });

  testWidgets('[unary] 1 2 x³ = 1728', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "x³"], "1728", "unary");
  });

  testWidgets('[unary] 0 . 2 5 x³ = 0.015625', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "2", "5", "x³"], "0.015625", "unary");
  });

  testWidgets('[unary] 1 0 0 x³ = 1000000', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "x³"], "1000000", "unary");
  });

  testWidgets('[unary] 0 . 1 x³ = 0.001', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "1", "x³"], "0.001", "unary");
  });

  testWidgets('[unary] 0 1/x = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", "1/x"], "Error", "unary");
  });

  testWidgets('[unary] 1 1/x = 1', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "1/x"], "1", "unary");
  });

  testWidgets('[unary] 2 1/x = 0.5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "1/x"], "0.5", "unary");
  });

  testWidgets('[unary] 5 1/x = 0.2', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "1/x"], "0.2", "unary");
  });

  testWidgets('[unary] 7 1/x = 0.1428571429', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "1/x"], "0.1428571429", "unary");
  });

  testWidgets('[unary] 0 . 5 1/x = 2', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "1/x"], "2", "unary");
  });

  testWidgets('[unary] 1 . 5 1/x = 0.6666666667', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", ".", "5", "1/x"], "0.6666666667", "unary");
  });

  testWidgets('[unary] 9 1/x = 0.1111111111', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["9", "1/x"], "0.1111111111", "unary");
  });

  testWidgets('[unary] 1 2 1/x = 0.08333333333', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "1/x"], "0.08333333333", "unary");
  });

  testWidgets('[unary] 0 . 2 5 1/x = 4', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "2", "5", "1/x"], "4", "unary");
  });

  testWidgets('[unary] 1 0 0 1/x = 0.01', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "1/x"], "0.01", "unary");
  });

  testWidgets('[unary] 0 . 1 1/x = 10', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "1", "1/x"], "10", "unary");
  });

  testWidgets('[unary] 0 x! = 1', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", "x!"], "1", "unary");
  });

  testWidgets('[unary] 1 x! = 1', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "x!"], "1", "unary");
  });

  testWidgets('[unary] 2 x! = 2', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "x!"], "2", "unary");
  });

  testWidgets('[unary] 5 x! = 120', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "x!"], "120", "unary");
  });

  testWidgets('[unary] 7 x! = 5040', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "x!"], "5040", "unary");
  });

  testWidgets('[unary] 0 . 5 x! = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "x!"], "Error", "unary");
  });

  testWidgets('[unary] 1 . 5 x! = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", ".", "5", "x!"], "Error", "unary");
  });

  testWidgets('[unary] 9 x! = 362880', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["9", "x!"], "362880", "unary");
  });

  testWidgets('[unary] 1 2 x! = 479001600', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "x!"], "479001600", "unary");
  });

  testWidgets('[unary] 0 . 2 5 x! = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "2", "5", "x!"], "Error", "unary");
  });

  testWidgets('[unary] 1 0 0 x! = 9.332621544e+157', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "x!"], "9.332621544e+157", "unary");
  });

  testWidgets('[unary] 0 . 1 x! = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "1", "x!"], "Error", "unary");
  });

  testWidgets('[unary] 0 |x| = 0', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", "|x|"], "0", "unary");
  });

  testWidgets('[unary] 1 |x| = 1', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "|x|"], "1", "unary");
  });

  testWidgets('[unary] 2 |x| = 2', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "|x|"], "2", "unary");
  });

  testWidgets('[unary] 5 |x| = 5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "|x|"], "5", "unary");
  });

  testWidgets('[unary] 7 |x| = 7', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "|x|"], "7", "unary");
  });

  testWidgets('[unary] 0 . 5 |x| = 0.5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "|x|"], "0.5", "unary");
  });

  testWidgets('[unary] 1 . 5 |x| = 1.5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", ".", "5", "|x|"], "1.5", "unary");
  });

  testWidgets('[unary] 9 |x| = 9', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["9", "|x|"], "9", "unary");
  });

  testWidgets('[unary] 1 2 |x| = 12', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "|x|"], "12", "unary");
  });

  testWidgets('[unary] 0 . 2 5 |x| = 0.25', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "2", "5", "|x|"], "0.25", "unary");
  });

  testWidgets('[unary] 1 0 0 |x| = 100', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "|x|"], "100", "unary");
  });

  testWidgets('[unary] 0 . 1 |x| = 0.1', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "1", "|x|"], "0.1", "unary");
  });

  testWidgets('[unary] π x² = 9.869604401', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["π", "x²"], "9.869604401", "unary");
  });

  testWidgets('[unary] e = 2.718281828', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["e"], "2.718281828", "unary");
  });

  testWidgets('[unary] e x² = 7.389056099', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["e", "x²"], "7.389056099", "unary");
  });

  testWidgets('[unary] π x! = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["π", "x!"], "Error", "unary");
  });

  testWidgets('[nthroot] 1 6 ⁿ√ 2 = 4', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "6", "ⁿ√", "2"], "4", "nthroot");
  });

  testWidgets('[nthroot] 1 6 ⁿ√ 3 = 2.5198421', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "6", "ⁿ√", "3"], "2.5198421", "nthroot");
  });

  testWidgets('[nthroot] 1 6 ⁿ√ 4 = 2', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "6", "ⁿ√", "4"], "2", "nthroot");
  });

  testWidgets('[nthroot] 1 6 ⁿ√ 5 = 1.741101127', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "6", "ⁿ√", "5"], "1.741101127", "nthroot");
  });

  testWidgets('[nthroot] 8 ⁿ√ 2 = 2.828427125', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["8", "ⁿ√", "2"], "2.828427125", "nthroot");
  });

  testWidgets('[nthroot] 8 ⁿ√ 3 = 2', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["8", "ⁿ√", "3"], "2", "nthroot");
  });

  testWidgets('[nthroot] 8 ⁿ√ 4 = 1.681792831', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["8", "ⁿ√", "4"], "1.681792831", "nthroot");
  });

  testWidgets('[nthroot] 8 ⁿ√ 5 = 1.515716567', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["8", "ⁿ√", "5"], "1.515716567", "nthroot");
  });

  testWidgets('[nthroot] 2 7 ⁿ√ 2 = 5.196152423', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "7", "ⁿ√", "2"], "5.196152423", "nthroot");
  });

  testWidgets('[nthroot] 2 7 ⁿ√ 3 = 3', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "7", "ⁿ√", "3"], "3", "nthroot");
  });

  testWidgets('[nthroot] 2 7 ⁿ√ 4 = 2.279507057', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "7", "ⁿ√", "4"], "2.279507057", "nthroot");
  });

  testWidgets('[nthroot] 2 7 ⁿ√ 5 = 1.933182045', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "7", "ⁿ√", "5"], "1.933182045", "nthroot");
  });

  testWidgets('[nthroot] 8 1 ⁿ√ 2 = 9', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["8", "1", "ⁿ√", "2"], "9", "nthroot");
  });

  testWidgets('[nthroot] 8 1 ⁿ√ 3 = 4.326748711', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["8", "1", "ⁿ√", "3"], "4.326748711", "nthroot");
  });

  testWidgets('[nthroot] 8 1 ⁿ√ 4 = 3', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["8", "1", "ⁿ√", "4"], "3", "nthroot");
  });

  testWidgets('[nthroot] 8 1 ⁿ√ 5 = 2.408224685', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["8", "1", "ⁿ√", "5"], "2.408224685", "nthroot");
  });

  testWidgets('[nthroot] 3 2 ⁿ√ 2 = 5.656854249', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["3", "2", "ⁿ√", "2"], "5.656854249", "nthroot");
  });

  testWidgets('[nthroot] 3 2 ⁿ√ 3 = 3.174802104', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["3", "2", "ⁿ√", "3"], "3.174802104", "nthroot");
  });

  testWidgets('[nthroot] 3 2 ⁿ√ 4 = 2.37841423', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["3", "2", "ⁿ√", "4"], "2.37841423", "nthroot");
  });

  testWidgets('[nthroot] 3 2 ⁿ√ 5 = 2', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["3", "2", "ⁿ√", "5"], "2", "nthroot");
  });

  testWidgets('[pow] 2 xʸ 3 = = 8', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "xʸ", "3", "="], "8", "pow");
  });

  testWidgets('[pow] 2 xʸ 8 = = 256', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "xʸ", "8", "="], "256", "pow");
  });

  testWidgets('[pow] 3 xʸ 2 = = 9', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["3", "xʸ", "2", "="], "9", "pow");
  });

  testWidgets('[pow] 5 xʸ 3 = = 125', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "xʸ", "3", "="], "125", "pow");
  });

  testWidgets('[pow] 9 xʸ 0 . 5 = = 3', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["9", "xʸ", "0", ".", "5", "="], "3", "pow");
  });

  testWidgets('[pow] 2 xʸ 1 0 = = 1024', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "xʸ", "1", "0", "="], "1024", "pow");
  });

  testWidgets('[pow] 7 xʸ 2 = = 49', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "xʸ", "2", "="], "49", "pow");
  });

  testWidgets('[binary] 7 ÷ 2 = = 3.5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "÷", "2", "="], "3.5", "binary");
  });

  testWidgets('[binary] 3 ÷ 4 = = 0.75', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["3", "÷", "4", "="], "0.75", "binary");
  });

  testWidgets('[binary] 9 ÷ 4 = = 2.25', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["9", "÷", "4", "="], "2.25", "binary");
  });

  testWidgets('[binary] 2 ÷ 3 = = 0.6666666667', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "÷", "3", "="], "0.6666666667", "binary");
  });

  testWidgets('[binary] 8 ÷ 6 = = 1.333333333', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["8", "÷", "6", "="], "1.333333333", "binary");
  });

  testWidgets('[binary] 5 ÷ 5 = = 1', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "÷", "5", "="], "1", "binary");
  });

  testWidgets('[binary] 1 2 ÷ 7 = = 1.714285714', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "÷", "7", "="], "1.714285714", "binary");
  });

  testWidgets('[binary] 1 ÷ 3 = = 0.3333333333', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "÷", "3", "="], "0.3333333333", "binary");
  });

  testWidgets('[binary] 0 . 5 ÷ 2 = = 0.25', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "÷", "2", "="], "0.25", "binary");
  });

  testWidgets('[binary] 1 0 0 ÷ 7 = = 14.28571429', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "÷", "7", "="], "14.28571429", "binary");
  });

  testWidgets('[binary] 6 ÷ 0 = = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["6", "÷", "0", "="], "Error", "binary");
  });

  testWidgets('[binary] 7 × 2 = = 14', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "×", "2", "="], "14", "binary");
  });

  testWidgets('[binary] 3 × 4 = = 12', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["3", "×", "4", "="], "12", "binary");
  });

  testWidgets('[binary] 9 × 4 = = 36', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["9", "×", "4", "="], "36", "binary");
  });

  testWidgets('[binary] 2 × 3 = = 6', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "×", "3", "="], "6", "binary");
  });

  testWidgets('[binary] 8 × 6 = = 48', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["8", "×", "6", "="], "48", "binary");
  });

  testWidgets('[binary] 5 × 5 = = 25', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "×", "5", "="], "25", "binary");
  });

  testWidgets('[binary] 1 2 × 7 = = 84', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "×", "7", "="], "84", "binary");
  });

  testWidgets('[binary] 1 × 3 = = 3', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "×", "3", "="], "3", "binary");
  });

  testWidgets('[binary] 0 . 5 × 2 = = 1', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "×", "2", "="], "1", "binary");
  });

  testWidgets('[binary] 1 0 0 × 7 = = 700', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "×", "7", "="], "700", "binary");
  });

  testWidgets('[binary] 6 × 0 = = 0', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["6", "×", "0", "="], "0", "binary");
  });

  testWidgets('[binary] 7 - 2 = = 5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "-", "2", "="], "5", "binary");
  });

  testWidgets('[binary] 3 - 4 = = -1', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["3", "-", "4", "="], "-1", "binary");
  });

  testWidgets('[binary] 9 - 4 = = 5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["9", "-", "4", "="], "5", "binary");
  });

  testWidgets('[binary] 2 - 3 = = -1', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "-", "3", "="], "-1", "binary");
  });

  testWidgets('[binary] 8 - 6 = = 2', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["8", "-", "6", "="], "2", "binary");
  });

  testWidgets('[binary] 5 - 5 = = 0', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "-", "5", "="], "0", "binary");
  });

  testWidgets('[binary] 1 2 - 7 = = 5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "-", "7", "="], "5", "binary");
  });

  testWidgets('[binary] 1 - 3 = = -2', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "-", "3", "="], "-2", "binary");
  });

  testWidgets('[binary] 0 . 5 - 2 = = -1.5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "-", "2", "="], "-1.5", "binary");
  });

  testWidgets('[binary] 1 0 0 - 7 = = 93', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "-", "7", "="], "93", "binary");
  });

  testWidgets('[binary] 6 - 0 = = 6', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["6", "-", "0", "="], "6", "binary");
  });

  testWidgets('[binary] 7 + 2 = = 9', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "+", "2", "="], "9", "binary");
  });

  testWidgets('[binary] 3 + 4 = = 7', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["3", "+", "4", "="], "7", "binary");
  });

  testWidgets('[binary] 9 + 4 = = 13', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["9", "+", "4", "="], "13", "binary");
  });

  testWidgets('[binary] 2 + 3 = = 5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "+", "3", "="], "5", "binary");
  });

  testWidgets('[binary] 8 + 6 = = 14', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["8", "+", "6", "="], "14", "binary");
  });

  testWidgets('[binary] 5 + 5 = = 10', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "+", "5", "="], "10", "binary");
  });

  testWidgets('[binary] 1 2 + 7 = = 19', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "+", "7", "="], "19", "binary");
  });

  testWidgets('[binary] 1 + 3 = = 4', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "+", "3", "="], "4", "binary");
  });

  testWidgets('[binary] 0 . 5 + 2 = = 2.5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "+", "2", "="], "2.5", "binary");
  });

  testWidgets('[binary] 1 0 0 + 7 = = 107', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "+", "7", "="], "107", "binary");
  });

  testWidgets('[binary] 6 + 0 = = 6', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["6", "+", "0", "="], "6", "binary");
  });

  testWidgets('[prec] 2 + 3 × 4 = = 14', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "+", "3", "×", "4", "="], "14", "prec");
  });

  testWidgets('[prec] 2 × 3 + 4 = = 10', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "×", "3", "+", "4", "="], "10", "prec");
  });

  testWidgets('[prec] 2 + 3 + 4 = = 9', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "+", "3", "+", "4", "="], "9", "prec");
  });

  testWidgets('[prec] 2 × 3 × 4 = = 24', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "×", "3", "×", "4", "="], "24", "prec");
  });

  testWidgets('[prec] 1 0 0 ÷ 4 ÷ 5 = = 5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "÷", "4", "÷", "5", "="], "5", "prec");
  });

  testWidgets('[prec] 2 x² + 3 x² = = 49', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "x²", "+", "3", "x²", "="], "49", "prec");
  });

  testWidgets('[prec] 1 + 2 × 3 = = 7', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "+", "2", "×", "3", "="], "7", "prec");
  });

  testWidgets('[paren] 2 × ( 1 + 2 ) = = 6', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "×", "(", "1", "+", "2", ")", "="], "6", "paren");
  });

  testWidgets('[paren] ( 2 + 3 ) × 4 = = 20', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["(", "2", "+", "3", ")", "×", "4", "="], "20", "paren");
  });

  testWidgets('[paren] ( ( 2 + 3 ) × 4 ) = = 20', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["(", "(", "2", "+", "3", ")", "×", "4", ")", "="], "20", "paren");
  });

  testWidgets('[paren] 1 0 0 - ( 2 + 3 ) × 2 = = 90', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "-", "(", "2", "+", "3", ")", "×", "2", "="], "90", "paren");
  });

  testWidgets('[sign] 5 ± = -5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "±"], "-5", "sign");
  });

  testWidgets('[sign] 5 ± ± = 5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "±", "±"], "5", "sign");
  });

  testWidgets('[sign] 5 ± ± ± = -5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "±", "±", "±"], "-5", "sign");
  });

  testWidgets('[sign] 2 + 3 ± = -1', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "+", "3", "±"], "-1", "sign");
  });

  testWidgets('[sign] 2 - 3 ± = 5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "-", "3", "±"], "5", "sign");
  });

  testWidgets('[sign] 1 2 + 4 5 ± = -33', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "+", "4", "5", "±"], "-33", "sign");
  });

  testWidgets('[sign] 0 . 5 ± = -0.5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "±"], "-0.5", "sign");
  });

  testWidgets('[sign] 0 . 5 ± ± = 0.5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "±", "±"], "0.5", "sign");
  });

  testWidgets('[pct] 5 0 % = 0.5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "0", "%"], "0.5", "pct");
  });

  testWidgets('[pct] 2 0 0 % = 2', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "0", "0", "%"], "2", "pct");
  });

  testWidgets('[pct] 1 0 0 0 % = 10', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "0", "0", "0", "%"], "10", "pct");
  });

  testWidgets('[dot] 0 . 5 = 0.5', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5"], "0.5", "dot");
  });

  testWidgets('[dot] 1 . 2 × 2 = = 2.4', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", ".", "2", "×", "2", "="], "2.4", "dot");
  });

  testWidgets('[del] 7 8 DEL = 7', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "8", "DEL"], "7", "del");
  });

  testWidgets('[del] 7 8 DEL DEL = ', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["7", "8", "DEL", "DEL"], "", "del");
  });

  testWidgets('[del] 1 2 + 3 DEL DEL DEL = 1', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "+", "3", "DEL", "DEL", "DEL"], "1", "del");
  });

  testWidgets('[ac] 9 9 AC = ', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["9", "9", "AC"], "", "ac");
  });

  testWidgets('[ac] 5 x² AC = ', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "x²", "AC"], "", "ac");
  });

  testWidgets('[err] 5 ÷ 0 = = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "÷", "0", "="], "Error", "err");
  });

  testWidgets('[err] 0 √ 1/x = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", "√", "1/x"], "Error", "err");
  });

  testWidgets('[err] 0 log = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", "log"], "Error", "err");
  });

  testWidgets('[err] 0 ln = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", "ln"], "Error", "err");
  });

  testWidgets('[err] 5 asin = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["5", "asin"], "Error", "err");
  });

  testWidgets('[err] 2 acos = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "acos"], "Error", "err");
  });

  testWidgets('[err] 1 ± √ = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "±", "√"], "Error", "err");
  });

  testWidgets('[err] 0 . 5 x! = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["0", ".", "5", "x!"], "Error", "err");
  });

  testWidgets('[err] 2 0 0 x! = Error', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "0", "0", "x!"], "Error", "err");
  });

  testWidgets('[err] 1 + = ', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "+"], "", "err");
  });

  testWidgets('[expr] 1 2 + 3 DEL = 12+', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "+", "3", "DEL"], "12+", "expr");
  });

  testWidgets('[expr] 1 2 + 3 DEL DEL DEL = 1', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "+", "3", "DEL", "DEL", "DEL"], "1", "expr");
  });

  testWidgets('[expr] 2 + 3 ± = 2+-3', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "+", "3", "±"], "2+-3", "expr");
  });

  testWidgets('[expr] 2 + 3 ± ± = 2+3', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "+", "3", "±", "±"], "2+3", "expr");
  });

  testWidgets('[expr] 2 - 3 ± = 2--3', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "-", "3", "±"], "2--3", "expr");
  });

  testWidgets('[expr] 1 2 + 4 5 ± = 12+-45', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "2", "+", "4", "5", "±"], "12+-45", "expr");
  });

  testWidgets('[expr] 2 + 3 x² = 25', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "+", "3", "x²"], "25", "expr");
  });

  testWidgets('[expr] 2 + 3 x² + 4 = 25+4', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["2", "+", "3", "x²", "+", "4"], "25+4", "expr");
  });

  testWidgets('[expr] 1 6 ⁿ√ 2 = 16^(1/2', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "6", "ⁿ√", "2"], "16^(1/2", "expr");
  });

  testWidgets('[expr] 1 6 ⁿ√ 2 ) = 16^(1/2)', (t) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await t.binding.setSurfaceSize(surface);
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: ScientificKeypad())),
      ),
    ));
    await t.pumpAndSettle();
    await run(t, c, ["1", "6", "ⁿ√", "2", ")"], "16^(1/2)", "expr");
  });

}
