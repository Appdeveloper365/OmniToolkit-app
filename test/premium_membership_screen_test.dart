import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/screens/premium_membership_screen.dart';

void main() {
  testWidgets('shows only active devices entry for signed-in users',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const PremiumMembershipScreen(signedInEmail: 'buyer@example.com'),
        routes: {
          '/active-devices': (_) => const Placeholder(),
          '/membership-status': (_) => const SizedBox.shrink(),
        },
      ),
    );

    expect(find.text('Active Devices'), findsOneWidget);
    expect(find.text('Verify Membership'), findsNothing);

    await tester.tap(find.text('Active Devices'));
    await tester.pumpAndSettle();

    expect(find.byType(Placeholder), findsOneWidget);
  });

  testWidgets('shows verify membership entry when signed out', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const PremiumMembershipScreen(),
        routes: {
          '/active-devices': (_) => const SizedBox.shrink(),
          '/membership-status': (_) => const Placeholder(),
        },
      ),
    );

    expect(find.text('Active Devices'), findsOneWidget);
    expect(find.text('Verify Membership'), findsOneWidget);

    await tester.tap(find.text('Verify Membership'));
    await tester.pumpAndSettle();

    expect(find.byType(Placeholder), findsOneWidget);
  });
}
