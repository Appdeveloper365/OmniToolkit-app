/// FILE: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'core/data/asset_importer.dart';
import 'core/navigation/main_navigation.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/billing_notice_screen.dart';
import 'screens/entitlement_check_screen.dart';
import 'screens/share_target_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeLocalServices();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  } catch (error, stackTrace) {
    debugPrint('[Firebase] Initialization failed; dashboard remains available: $error\n$stackTrace');
  }
  try {
    await AssetImporter.importFirstLaunch();
  } catch (error, stackTrace) {
    debugPrint('[AssetImporter] Failed to import assets: $error\n$stackTrace');
  }
  runApp(const ProviderScope(child: OmniToolkitApp()));
}

void _initializeLocalServices() {
  try {
    tz_data.initializeTimeZones();
  } catch (error, stackTrace) {
    debugPrint('[App] Timezone initialization failed: $error\n$stackTrace');
  }
}

class OmniToolkitApp extends ConsumerWidget {
  const OmniToolkitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'OmniToolkit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const MainNavigation(),
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');
        if (uri.path == '/billing-notice' || uri.path == '/account') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const BillingNoticeScreen(),
          );
        }
        if (uri.path == '/membership-status') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const EntitlementCheckScreen(),
          );
        }
        if (uri.path == '/share') {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => ShareTargetScreen(
              title: uri.queryParameters['title'],
              text: uri.queryParameters['text'],
              url: uri.queryParameters['url'],
            ),
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MainNavigation(),
        );
      },
    );
  }
}