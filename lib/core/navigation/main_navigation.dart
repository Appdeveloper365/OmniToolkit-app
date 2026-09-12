/// FILE: lib/core/navigation/main_navigation.dart
import 'package:flutter/material.dart';

import '../../modules/calculator/screens/calculator_screen.dart';
import '../../modules/calendar/screens/calendar_screen.dart';
import '../../modules/lookup/screens/lookup_screen.dart';
import '../../modules/password/password_screen.dart';
import '../../modules/radio/screens/radio_screen.dart';
import '../membership/membership_service.dart';
import '../purchase/pending_purchase_action.dart';
import '../purchase/radio_access_gate.dart';
import '../settings/settings_screen.dart';
import '../theme/app_logo.dart';

/// Root scaffold hosting navigation for all modules and settings.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  /// Index of the Radio/TV destination, the only module gated behind a
  /// one-time Lifetime Access purchase. Every other destination is free.
  static const _radioIndex = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _completePendingVerification());
  }

  /// Silently completes a Firebase email-link sign-in if the app was
  /// re-opened via the verification link, then resumes whichever purchase
  /// action (Unlock or Restore) triggered the email. This never blocks the
  /// UI; OmniToolkit itself has no startup gate.
  Future<void> _completePendingVerification() async {
    final service = MembershipService();
    try {
      if (!await service.isVerificationLink()) return;
      final pendingEmail = await service.pendingEmail();
      if (pendingEmail == null) return;
      await service.completeVerification(pendingEmail);
    } catch (_) {
      // Nothing to resume; the user can retry Unlock/Restore manually.
      return;
    }
    if (!mounted) return;
    final action = await PendingPurchaseActionStore.consume();
    if (action == null || !mounted) return;
    switch (action) {
      case PendingPurchaseAction.unlock:
        Navigator.of(context).pushNamed('/billing-notice');
        break;
      case PendingPurchaseAction.restore:
        await RestorePurchaseFlow.run(context);
        break;
    }
  }

  void _selectDestination(int index) {
    if (index == _radioIndex) {
      RadioAccessGate.ensureAccess(context, () {
        if (mounted) setState(() => _index = index);
      });
      return;
    }
    setState(() => _index = index);
  }

  static const _screens = [
    CalendarScreen(),
    CalculatorScreen(),
    RadioScreen(),
    LookupScreen(),
    PasswordScreen(),
    SettingsScreen(),
  ];

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendar'),
    NavigationDestination(icon: Icon(Icons.calculate_outlined), selectedIcon: Icon(Icons.calculate), label: 'Calculator'),
    NavigationDestination(icon: Icon(Icons.radio_outlined), selectedIcon: Icon(Icons.radio), label: 'Radio/TV'),
    NavigationDestination(icon: Icon(Icons.location_searching_outlined), selectedIcon: Icon(Icons.location_on), label: 'Lookup'),
    NavigationDestination(icon: Icon(Icons.password_outlined), selectedIcon: Icon(Icons.password), label: 'Password'),
    NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;

    if (isWide) {
      return Scaffold(
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: IntrinsicHeight(
                        child: NavigationRail(
                          leading: const Padding(
                            padding: EdgeInsets.only(top: 16, bottom: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppLogo(size: 84),
                                SizedBox(height: 4),
                              ],
                            ),
                          ),
                          selectedIndex: _index,
                          onDestinationSelected: _selectDestination,
                          labelType: NavigationRailLabelType.all,
                          destinations: _destinations
                              .map((d) => NavigationRailDestination(
                                    icon: d.icon,
                                    selectedIcon: d.selectedIcon,
                                    label: Text(d.label),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: _screens[_index]),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _screens[_index]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _selectDestination,
        destinations: _destinations,
      ),
    );
  }
}
