import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:omnitoolkit/main.dart';

void main() {
  testWidgets('OmniToolkit app boots directly to navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: OmniToolkitApp()));
    await tester.pump();

    expect(find.text('Calendar'), findsWidgets);
    expect(find.text('Calculator'), findsWidgets);
  });
}
