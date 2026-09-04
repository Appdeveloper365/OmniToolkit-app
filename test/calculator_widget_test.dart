import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/modules/calculator/screens/simple_calculator_tab.dart';

void main() {
  testWidgets('Calculator keypad tap updates input and result', (tester) async {
    // The premium keypad is taller than the default 800x600 test surface;
    // enlarge it so every key is reachable by tap().
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SimpleCalculatorTab(),
          ),
        ),
      ),
    );

    // Tap 7
    await tester.tap(find.text('7'));
    await tester.pump();

    // Tap +
    await tester.tap(find.text('+'));
    await tester.pump();

    // Tap 5
    await tester.tap(find.text('5'));
    await tester.pump();

    // Live result should show 12 in the display.
    expect(find.text('12'), findsOneWidget);

    // Tap =
    await tester.tap(find.text('='));
    await tester.pump();

    // Both the expression and result now read 12.
    expect(find.text('12'), findsWidgets);

    // Pressing AC clears the session back to 0.
    await tester.tap(find.text('AC'));
    await tester.pump();
    expect(find.text('0'), findsWidgets);
  });

  testWidgets('DEL removes the last character of the expression', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SimpleCalculatorTab(),
          ),
        ),
      ),
    );

    await tester.tap(find.text('7'));
    await tester.pump();
    await tester.tap(find.text('DEL'));
    await tester.pump();

    expect(find.text('0'), findsWidgets);
  });
}