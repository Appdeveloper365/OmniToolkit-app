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
    expect(find.text('Confirm Your Billing Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Confirm Email'), findsOneWidget);
    expect(find.text('Continue With Payment'), findsOneWidget);
  });

  testWidgets(
      'BillingNoticeScreen keeps Continue disabled until emails match and '
      'the disclaimer is accepted, then enables it once both are satisfied',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BillingNoticeScreen(),
      ),
    );
    await tester.pump();

    FilledButton continueButton() =>
        tester.widget<FilledButton>(find.widgetWithText(
            FilledButton, 'Continue With Payment'));

    // Nothing entered yet: disabled.
    expect(continueButton().onPressed, isNull);

    // Fill in a valid email but leave the confirm field blank/mismatched.
    await tester.enterText(
        find.widgetWithText(TextField, 'Email'), 'buyer@example.com');
    await tester.enterText(
        find.widgetWithText(TextField, 'Confirm Email'), 'typo@example.com');
    await tester.pump();
    expect(continueButton().onPressed, isNull);
    expect(find.text('Emails do not match.'), findsOneWidget);

    // Fix the confirmation email so it matches, but disclaimer still unchecked.
    await tester.enterText(
        find.widgetWithText(TextField, 'Confirm Email'), 'buyer@example.com');
    await tester.pump();
    expect(continueButton().onPressed, isNull);

    // Accept the disclaimer -- now Continue With Payment should be enabled.
    final disclaimerFinder =
        find.text('I acknowledge and agree to the information above.');
    await tester.ensureVisible(disclaimerFinder);
    await tester.pump();
    await tester.tap(disclaimerFinder);
    await tester.pump();
    expect(continueButton().onPressed, isNotNull);
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