/// FILE: lib/core/navigation/route_guard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../screens/account_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/payment_cancelled_screen.dart';
import '../../screens/payment_success_screen.dart';
import '../../screens/pricing_screen.dart';
import '../auth/auth_provider.dart';
import 'main_navigation.dart';

Route<dynamic> generateProtectedRoutes(RouteSettings settings, WidgetRef ref) {
  final authState = ref.watch(appAuthProvider);
  final uri = Uri.parse(settings.name ?? '/');
  final path = uri.path;

  // Unauthenticated -> Redirect to Login
  if (!authState.isAuthenticated) {
    if (path == '/pricing' || path == '/payment-success' || path == '/payment-cancelled') {
      // Allow public checkout return views
    } else {
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }

  // Authenticated user check entitlement
  final user = authState.userModel;

  if (user != null && !user.isEntitled) {
    // Trial expired & Unpaid -> Force Pricing Page
    if (path != '/account' && path != '/payment-success' && path != '/payment-cancelled') {
      return MaterialPageRoute(builder: (_) => const PricingScreen());
    }
  }

  // Route Mapping
  switch (path) {
    case '/login':
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case '/pricing':
      return MaterialPageRoute(builder: (_) => const PricingScreen());
    case '/account':
      return MaterialPageRoute(builder: (_) => const AccountScreen());
    case '/payment-success':
      return MaterialPageRoute(builder: (_) => const PaymentSuccessScreen());
    case '/payment-cancelled':
      return MaterialPageRoute(builder: (_) => const PaymentCancelledScreen());
    case '/':
    default:
      return MaterialPageRoute(builder: (_) => const MainNavigation());
  }
}
