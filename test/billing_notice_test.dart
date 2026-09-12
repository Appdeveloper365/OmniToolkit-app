import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/screens/billing_notice_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('BillingNoticeScreen displays notice terms and disclaimer when unowned',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BillingNoticeScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Special Launch Pricing'), findsOneWidget);
    expect(find.text('OmniToolkit Lifetime Access'), findsOneWidget);
    expect(find.text('I acknowledge and agree to the information above.'),
        findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('BillingNoticeScreen displays verified UI when membership is already owned',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'membership.hasLifetimeAccess': true,
      'membership.email': 'purchaser@example.com',
      'membership.emailVerified': true,
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: BillingNoticeScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('✅ Lifetime Membership Verified'), findsWidgets);
    expect(find.text('World Radio Explorer has been unlocked.'), findsOneWidget);
    expect(find.text('Open Radio Directory'), findsOneWidget);
    expect(find.text('Return To Radio Directory'), findsOneWidget);
  });
}