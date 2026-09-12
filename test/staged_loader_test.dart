import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/core/purchase/staged_loader.dart';

void main() {
  testWidgets('StagedLoader renders heading and rotates status messages',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StagedLoader(
            heading: 'Checking Membership...',
            messages: ['Step 1...', 'Step 2...', 'Step 3...'],
          ),
        ),
      ),
    );

    expect(find.text('Checking Membership...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Step 1...'), findsOneWidget);

    // Advance past 1200ms to test timer-driven message advance
    await tester.pump(const Duration(milliseconds: 1300));
    expect(find.text('Step 2...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1300));
    expect(find.text('Step 3...'), findsOneWidget);

    // Cycles back to Step 1
    await tester.pump(const Duration(milliseconds: 1300));
    expect(find.text('Step 1...'), findsOneWidget);
  });
}