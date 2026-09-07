import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/screens/share_target_screen.dart';

void main() {
  testWidgets('ShareTargetScreen displays title, text, and url query params', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ShareTargetScreen(
          title: 'Example Page',
          text: 'Interesting article',
          url: 'https://example.com',
        ),
      ),
    );

    expect(find.text('Example Page'), findsOneWidget);
    expect(find.text('Interesting article'), findsOneWidget);
    expect(find.text('https://example.com'), findsOneWidget);
  });

  testWidgets('ShareTargetScreen handles missing parameters with null safety', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ShareTargetScreen(),
      ),
    );

    expect(find.text('Shared Content'), findsOneWidget);
    expect(find.text('No query parameters received. Open URL format:\n/share?title=Example&text=Hello&url=https://example.com'), findsOneWidget);
  });
}
