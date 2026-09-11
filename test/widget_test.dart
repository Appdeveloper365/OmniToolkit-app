// Basic smoke test verifying the OmniToolkit app requires an email before access.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:omnitoolkit/main.dart';

void main() {
  testWidgets('OmniToolkit app boots to the membership gate',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: OmniToolkitApp()));
    await tester.pump();

    expect(find.text('Welcome to OmniToolkit'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
  });
}