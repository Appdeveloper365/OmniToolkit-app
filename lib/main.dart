/// FILE: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'core/data/asset_importer.dart';
import 'core/navigation/route_guard.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/share_target_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: AppStartupGate(
        initializeApp: _initializeApplication,
        child: OmniToolkitApp(),
      ),
    ),
  );
}

Future<void> _initializeApplication() async {
  try {
    tz_data.initializeTimeZones();
    debugPrint('[App] Timezone initialized');
  } catch (e) {
    debugPrint('[App] Timezone initialization warning: $e');
  }

  try {
    await DefaultFirebaseOptions.initializeFirebaseApp();
    debugPrint('[Firebase] Successfully initialized');
  } catch (error, stackTrace) {
    debugPrint('[Firebase] Initialization failed: $error\n$stackTrace');
    debugPrint('[Firebase] Error description: ${DefaultFirebaseOptions.describeInitializationFailure(error)}');
  }

  try {
    await AssetImporter.importFirstLaunch();
    debugPrint('[App] Assets imported successfully');
  } catch (e) {
    debugPrint('[AssetImporter] Failed to import assets: $e');
  }

}

class AppStartupGate extends StatefulWidget {
  final Future<void> Function() initializeApp;
  final Widget child;

  const AppStartupGate({
    required this.initializeApp,
    required this.child,
    super.key,
  });

  @override
  State<AppStartupGate> createState() => _AppStartupGateState();
}

class _AppStartupGateState extends State<AppStartupGate> {
  late Future<void> _initFuture;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initFuture = widget.initializeApp().catchError((dynamic e) {
      setState(() {
        _error = e.toString();
      });
      throw e;
    });
  }

  void _retry() {
    setState(() {
      _error = null;
      _initFuture = widget.initializeApp().catchError((dynamic e) {
        setState(() {
          _error = e.toString();
        });
        throw e;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmniToolkit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (_error != null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Startup configuration problem')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[700],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'App startup failed while preparing offline data. Please retry.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _retry,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Preparing OmniToolkit',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          return widget.child;
        },
      ),
    );
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
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');

        // Match /share route for Web Share Target and query parameters
        if (uri.path == '/share') {
          final title = uri.queryParameters['title'];
          final text = uri.queryParameters['text'];
          final url = uri.queryParameters['url'];

          return MaterialPageRoute(
            settings: settings,
            builder: (_) => ShareTargetScreen(
              title: title,
              text: text,
              url: url,
            ),
          );
        }

        // Delegate all other routes to Protected Route Guard
        return generateProtectedRoutes(settings);
      },
    );
  }
}

