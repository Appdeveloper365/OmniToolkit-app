import 'package:flutter/material.dart';

import '../../modules/calculator/screens/calculator_screen.dart';
import '../../modules/calendar/screens/calendar_screen.dart';
import '../../modules/lookup/screens/lookup_screen.dart';
import '../../modules/password/password_screen.dart';
import '../../modules/radio/screens/radio_screen.dart';
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
        body: Row(
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
                    onDestinationSelected: (i) => setState(() => _index = i),
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
      );
    }

    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _destinations,
      ),
    );
  }
}
