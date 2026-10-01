/// FILE: lib/core/navigation/main_navigation.dart
import 'package:flutter/material.dart';

import '../../modules/calculator/screens/calculator_screen.dart';
import '../../modules/calendar/screens/calendar_screen.dart';
import '../../modules/lookup/screens/lookup_screen.dart';
import '../../modules/password/password_screen.dart';
import '../../modules/radio/screens/radio_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../membership/membership_service.dart';
import '../purchase/entitlement_watcher.dart';
import '../purchase/pending_purchase_action.dart';
import '../purchase/radio_access_gate.dart';
import '../purchase/radio_launch_controller.dart';
import '../settings/settings_screen.dart';
import '../theme/app_logo.dart';

/// Root scaffold hosting navigation for all modules and settings.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key, this.initialIndex = 0});

  /// Tab to open on first build -- used to land directly on Radio Explorer
  /// after a cold Stripe success-page reload recognizes an existing or
  /// just-completed purchase.
  final int initialIndex;

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _index = widget.initialIndex == _radioIndex ? 0 : widget.initialIndex;

  /// Index of the Radio/TV destination, the only module gated behind a
  /// one-time Lifetime Access purchase. Every other destination is free.
  static const _radioIndex = 2;

  @override
  void initState() {
    super.initState();
    RadioLaunchController.register(_openRadioTab);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.initialIndex == _radioIndex && mounted) {
        RadioAccessGate.ensureAccess(context, () {
          if (mounted) {
            setState(() => _index = _radioIndex);
          }
        });
      }
      await _completePendingVerification();
    });
  }

  @override
  void dispose() {
    RadioLaunchController.unregister(_openRadioTab);
    super.dispose();
  }

  /// Called by RadioLaunchController the instant EntitlementWatcher observes
  /// a real-time Firestore update marking the purchase complete. Pops any
  /// open dialogs/screens (e.g. Billing Notice) back to this root scaffold
  /// and jumps straight to the now-unlocked Radio Explorer tab.
  void _openRadioTab() {
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true)
        .popUntil((route) => route.isFirst);
    RadioAccessGate.ensureAccess(context, () {
      if (mounted) {
        setState(() => _index = _radioIndex);
      }
    });
  }

  /// Handles Firebase email-link sign-in callback when OmniToolkit is opened
  /// from a verification link.
  ///
  /// REQUIRED BEHAVIOR:
  /// 1. Read email from callback.
  /// 2. Check Firestore entitlement immediately.
  ///
  /// CASE A: hasLifetimeAccess = true
  /// -> Activate Membership
  /// -> Unlock Radio Directory
  ///
  /// CASE B: hasLifetimeAccess = false
  /// -> If this link was requested to complete a purchase (pending action
  ///    == unlock), skip straight to the payment screen -- the user already
  ///    confirmed purchase intent before the link was sent, so requiring
  ///    another dialog tap or email re-entry would be redundant/confusing.
  /// -> Otherwise (restore/undetermined intent), show "No Lifetime
  ///    Membership found" dialog with [Continue With Payment].
  ///
  /// Never shows the Verify Email dialog again or creates verification loops.
  Future<void> _completePendingVerification() async {
    final service = MembershipService();
    bool isLink = false;
    try {
      isLink = await service.isVerificationLink();
    } catch (_) {
      isLink = false;
    }
    if (!isLink) return;

    // 1. Read email from callback (link URL, localStorage, or auth session)
    String? email = service.extractEmailFromLink();
    email ??= await service.pendingEmail();
    email ??= FirebaseAuth.instance.currentUser?.email;

    if (email != null && email.isNotEmpty) {
      try {
        await service.completeVerification(email);
      } catch (e) {
        debugPrint('[_completePendingVerification] completeVerification: $e');
      }
    }

    final pendingAction = await PendingPurchaseActionStore.consume();
    if (!mounted) return;

    // 2. Check Firestore entitlement immediately
    final verifiedUser = service.verifiedUser;
    if (verifiedUser == null) {
      final checkEmail = email?.trim().toLowerCase() ?? '';
      if (checkEmail.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'We could not verify your membership right now. Please try again.',
          ),
        ));
        return;
      }

      MembershipState lookupState;
      try {
        lookupState = await service.lookupEntitlementByEmail(checkEmail);
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'We could not verify your membership right now. Please try again.',
          ),
        ));
        return;
      }

      if (!mounted) return;
      if (lookupState.hasLifetimeAccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'We found your lifetime membership. Sign in again to activate this device.',
          ),
        ));
        Navigator.of(context).pushNamed('/premium-membership');
        return;
      }

      EntitlementWatcher.instance.watch(checkEmail);
      if (pendingAction == PendingPurchaseAction.unlock) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Email verified. Continue with your purchase below.'),
        ));
        Navigator.of(context).pushNamed('/billing-notice');
        return;
      }
      _showNoLifetimeMembershipFoundDialog();
      return;
    }

    MembershipState membershipState;
    try {
      membershipState = await service.startOrRestore();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'We could not verify your membership right now. Please try again.',
        ),
      ));
      return;
    }

    if (!mounted) return;

    if (membershipState.hasLifetimeAccess) {
      if (membershipState.deviceLimitReached) {
        if (_index == _radioIndex) {
          setState(() => _index = 0);
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Device Limit Reached. This membership is active on the maximum number of devices.',
          ),
        ));
        Navigator.of(context).pushNamed('/premium-membership');
        return;
      }
      // CASE A: Activate Membership & Unlock Radio Directory
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Lifetime Membership Activated. World Radio Explorer is unlocked.',
        ),
      ));
      _openRadioTab();
    } else {
      // CASE B: No Lifetime Membership found.
      final verifiedEmail = verifiedUser.email;
      if (verifiedEmail != null && verifiedEmail.isNotEmpty) {
        EntitlementWatcher.instance.watch(verifiedEmail);
      }
      if (pendingAction == PendingPurchaseAction.unlock) {
        // This email link was requested specifically to complete a
        // purchase (RadioAccessGate "Unlock Now" / Account & Billing
        // "Send Verification Link"). The user already confirmed intent
        // to buy before this link was sent, so skip the extra
        // confirmation dialog and land directly on the payment screen
        // instead of asking them to tap through another dialog or
        // re-enter their email.
        //
        // But first: never pitch payment to someone who already paid.
        // The startOrRestore call above can miss a purchase whose Stripe
        // webhook was still in flight; checkEntitlementByEmail runs the
        // same self-healing check (Firestore + Stripe search) and, if it
        // finds the purchase, the follow-up startOrRestore registers this
        // device and unlocks Radio Explorer instead of opening checkout.
        var alreadyOwned = false;
        final checkEmail = verifiedEmail?.trim().toLowerCase() ?? '';
        if (checkEmail.isNotEmpty) {
          try {
            final recheck = await service.lookupEntitlementByEmail(checkEmail);
            alreadyOwned = recheck.hasLifetimeAccess;
          } catch (_) {
            alreadyOwned = false;
          }
        }
        if (!mounted) return;
        if (alreadyOwned) {
          try {
            final activated = await service.startOrRestore();
            if (!mounted) return;
            if (activated.hasLifetimeAccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                  'Lifetime Membership Activated. World Radio Explorer is unlocked.',
                ),
              ));
              _openRadioTab();
              return;
            }
          } catch (_) {
            // Fall through to the dialog below.
          }
          if (!mounted) return;
          _showNoLifetimeMembershipFoundDialog();
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Email verified. Continue with your purchase below.'),
        ));
        Navigator.of(context).pushNamed('/billing-notice');
      } else {
        // Restore/undetermined intent: offer Continue With Payment instead
        // of forcing straight into checkout.
        _showNoLifetimeMembershipFoundDialog();
      }
    }
  }

  void _showNoLifetimeMembershipFoundDialog() {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('No Lifetime Membership found'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('World Radio Explorer requires Lifetime Access.'),
            SizedBox(height: 16),
            Text(
              'Special Launch Pricing',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('OmniToolkit Lifetime Access'),
            Text(r'$9.99 USD (Launch Price)'),
            SizedBox(height: 4),
            Text(
              'Available for the first 500 customers.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Not Now'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.of(context).pushNamed('/billing-notice');
            },
            child: const Text('Continue With Payment'),
          ),
        ],
      ),
    );
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
