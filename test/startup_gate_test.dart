import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/main.dart';

void main() {
  testWidgets('startup gate shows loading before initialization completes',
      (WidgetTester tester) async {
    final completer = Completer<void>();

    await tester.pumpWidget(
      AppStartupGate(
        initializeApp: () => completer.future,
        child: const Placeholder(),
      ),
    );

    expect(find.text('Preparing OmniToolkit'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete();
    await tester.pumpAndSettle();

    expect(find.byType(Placeholder), findsOneWidget);
  });

  testWidgets('startup gate shows retryable error and can recover',
      (WidgetTester tester) async {
    var attempts = 0;

    Future<void> initializer() async {
      attempts++;
      if (attempts == 1) {
        throw Exception('boom');
      }
    }

    await tester.pumpWidget(
      AppStartupGate(
        initializeApp: initializer,
        child: const Placeholder(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Startup configuration problem'), findsOneWidget);
    expect(find.text('App startup failed while preparing offline data. Please retry.'),
        findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.byType(Placeholder), findsOneWidget);
  });
}
