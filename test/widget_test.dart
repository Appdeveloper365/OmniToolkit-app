// Basic smoke test verifying the OmniToolkit app boots and shows its
// bottom navigation destinations.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:omnitoolkit/core/auth/auth_provider.dart';
import 'package:omnitoolkit/core/auth/user_model.dart';
import 'package:omnitoolkit/main.dart';

class TestAuthNotifier extends AppAuthNotifier {
  @override
  AuthState build() {
    final now = DateTime(2026, 1, 1);
    return AuthState(
      isAuthenticated: true,
      isLoading: false,
      userModel: UserModel(
        uid: 'test-user',
        email: 'test@example.com',
        createdAt: now,
        paymentStatus: 'paid',
        hasLifetimeAccess: true,
        trialStartDate: now,
        trialExpiresAt: now.add(const Duration(days: 7)),
        premiumActive: true,
      ),
    );
  }
}

void main() {
  testWidgets('OmniToolkit app boots and shows navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appAuthProvider.overrideWith(TestAuthNotifier.new)],
        child: const OmniToolkitApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Calendar'), findsWidgets);
    expect(find.text('Calculator'), findsWidgets);
  });
}
