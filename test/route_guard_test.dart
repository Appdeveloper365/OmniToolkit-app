import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:omnitoolkit/core/auth/auth_provider.dart';
import 'package:omnitoolkit/core/auth/user_model.dart';
import 'package:omnitoolkit/core/navigation/route_guard.dart';

class TestAuthNotifier extends AppAuthNotifier {
  TestAuthNotifier(this._initialState);

  final AuthState _initialState;

  @override
  AuthState build() => _initialState;

  void update(AuthState nextState) {
    state = nextState;
  }
}

UserModel _buildUser({
  required bool entitled,
}) {
  final now = DateTime(2026, 1, 1);
  return UserModel(
    uid: entitled ? 'paid-user' : 'trial-user',
    email: entitled ? 'paid@example.com' : 'trial@example.com',
    createdAt: now,
    paymentStatus: entitled ? 'paid' : 'unpaid',
    hasLifetimeAccess: entitled,
    trialStartDate: now,
    trialExpiresAt: entitled ? now.add(const Duration(days: 7)) : now,
    premiumActive: entitled,
  );
}

Future<TestAuthNotifier> _pumpGuardedApp(
  WidgetTester tester, {
  required AuthState initialState,
  String initialRoute = '/',
}) async {
  late final TestAuthNotifier notifier;
  final container = ProviderContainer(
    overrides: [
      appAuthProvider.overrideWith(() {
        notifier = TestAuthNotifier(initialState);
        return notifier;
      }),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        initialRoute: initialRoute,
        onGenerateRoute: generateProtectedRoutes,
      ),
    ),
  );

  return notifier;
}

void main() {
  testWidgets('loading route resolves to login without replacing the app tree',
      (WidgetTester tester) async {
    final notifier = await _pumpGuardedApp(
      tester,
      initialState: const AuthState(isLoading: true),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    notifier.update(const AuthState(isAuthenticated: false, isLoading: false));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Welcome to OmniToolkit'), findsOneWidget);
  });

  testWidgets('loading route resolves to main navigation for entitled users',
      (WidgetTester tester) async {
    final notifier = await _pumpGuardedApp(
      tester,
      initialState: const AuthState(isLoading: true),
    );

    notifier.update(
      AuthState(
        isAuthenticated: true,
        isLoading: false,
        userModel: _buildUser(entitled: true),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Calendar'), findsWidgets);
    expect(find.text('Calculator'), findsWidgets);
  });

  testWidgets('loading route resolves to pricing for unentitled users',
      (WidgetTester tester) async {
    final notifier = await _pumpGuardedApp(
      tester,
      initialState: const AuthState(isLoading: true),
    );

    notifier.update(
      AuthState(
        isAuthenticated: true,
        isLoading: false,
        userModel: _buildUser(entitled: false),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Unlock Lifetime Access'), findsOneWidget);
  });
}
