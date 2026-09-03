import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/modules/calculator/screens/simple_calculator_tab.dart';

void main() {
  testWidgets('Calculator keypad tap updates input and result', (tester) async {
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

    // Expect 12 in the result display
    expect(find.text('12'), findsOneWidget);

    // Tap =
    await tester.tap(find.text('='));
    await tester.pump();

    // Now input field contains 12
    expect(find.widgetWithText(TextField, '12'), findsOneWidget);
  });
}
