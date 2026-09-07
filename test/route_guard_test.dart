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

  testWidgets('authenticated users are redirected away from login',
      (WidgetTester tester) async {
    await _pumpGuardedApp(
      tester,
      initialState: AuthState(
        isAuthenticated: true,
        isLoading: false,
        userModel: _buildUser(entitled: true),
      ),
      initialRoute: '/login',
    );

    await tester.pump();

    expect(find.text('Welcome to OmniToolkit'), findsNothing);
    expect(find.text('Calendar'), findsWidgets);
  });

  testWidgets('authenticated unentitled users are redirected from login to pricing',
      (WidgetTester tester) async {
    await _pumpGuardedApp(
      tester,
      initialState: AuthState(
        isAuthenticated: true,
        isLoading: false,
        userModel: _buildUser(entitled: false),
      ),
      initialRoute: '/login',
    );

    await tester.pump();

    expect(find.text('Welcome to OmniToolkit'), findsNothing);
    expect(find.text('Unlock Lifetime Access'), findsOneWidget);
  });

  testWidgets('authenticated login redirect preserves supported next route',
      (WidgetTester tester) async {
    await _pumpGuardedApp(
      tester,
      initialState: AuthState(
        isAuthenticated: true,
        isLoading: false,
        userModel: _buildUser(entitled: true),
      ),
      initialRoute: '/login?next=%2Faccount',
    );

    await tester.pump();

    expect(find.text('Welcome to OmniToolkit'), findsNothing);
    expect(find.text('Account & Billing'), findsOneWidget);
  });

  testWidgets('authenticated login redirect ignores absolute next URLs',
      (WidgetTester tester) async {
    await _pumpGuardedApp(
      tester,
      initialState: AuthState(
        isAuthenticated: true,
        isLoading: false,
        userModel: _buildUser(entitled: true),
      ),
      initialRoute: '/login?next=https%3A%2F%2Fexample.com%2Faccount',
    );

    await tester.pump();

    expect(find.text('Welcome to OmniToolkit'), findsNothing);
    expect(find.text('Calendar'), findsWidgets);
  });

  testWidgets('authenticated login redirect ignores login as next route',
      (WidgetTester tester) async {
    await _pumpGuardedApp(
      tester,
      initialState: AuthState(
        isAuthenticated: true,
        isLoading: false,
        userModel: _buildUser(entitled: true),
      ),
      initialRoute: '/login?next=%2Flogin',
    );

    await tester.pump();

    expect(find.text('Welcome to OmniToolkit'), findsNothing);
    expect(find.text('Calendar'), findsWidgets);
  });
}
