/// FILE: lib/core/navigation/route_guard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../screens/account_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/payment_cancelled_screen.dart';
import '../../screens/payment_success_screen.dart';
import '../../screens/pricing_screen.dart';
import '../auth/auth_provider.dart';
import '../config/build_config.dart';
import 'main_navigation.dart';

Route<dynamic> generateProtectedRoutes(RouteSettings settings) {
  final uri = Uri.parse(settings.name ?? '/');
  return MaterialPageRoute(
    settings: settings,
    builder: (_) => _ProtectedRouteView(uri: uri),
  );
}

class _ProtectedRouteView extends ConsumerWidget {
  const _ProtectedRouteView({required this.uri});

  final Uri uri;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(appAuthProvider);
    final path = uri.path;

    if (authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (BuildConfig.isStoreBuild &&
        (path == '/pricing' ||
            path == '/payment-success' ||
            path == '/payment-cancelled')) {
      return const PricingScreen();
    }

    if (!authState.isAuthenticated) {
      if (path != '/pricing' &&
          path != '/payment-success' &&
          path != '/payment-cancelled') {
        return const LoginScreen();
      }
    }

    final user = authState.userModel;
    if (authState.isAuthenticated && path == '/login') {
      if (user == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      if (!user.isEntitled) {
        return const PricingScreen();
      }
      return const MainNavigation();
    }

    if (user != null &&
        !user.isEntitled &&
        path != '/pricing' &&
        path != '/account' &&
        path != '/payment-success' &&
        path != '/payment-cancelled') {
      return const PricingScreen();
    }

    switch (path) {
      case '/login':
        return const LoginScreen();
      case '/pricing':
        return const PricingScreen();
      case '/account':
        return const AccountScreen();
      case '/payment-success':
        return const PaymentSuccessScreen();
      case '/payment-cancelled':
        return const PaymentCancelledScreen();
      case '/':
      default:
        return const MainNavigation();
    }
  }
}
