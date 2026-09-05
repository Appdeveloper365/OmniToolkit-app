// Basic smoke test verifying the OmniToolkit app boots and shows its
// bottom navigation destinations.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:omnitoolkit/main.dart';

void main() {
  testWidgets('OmniToolkit app boots and shows navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: OmniToolkitApp()));
    await tester.pump();

    expect(find.text('Calendar'), findsWidgets);
    expect(find.text('Calculator'), findsWidgets);
  });
}
