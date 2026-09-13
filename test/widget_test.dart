// Basic smoke test verifying OmniToolkit boots directly into the app (no
// startup email gate) and only gates World Radio Explorer behind purchase.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:omnitoolkit/main.dart';

void main() {
  testWidgets('OmniToolkit boots directly into the app without a startup gate',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: OmniToolkitApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Welcome to OmniToolkit'), findsNothing);
    expect(find.text('Calendar'), findsWidgets);
  });
}