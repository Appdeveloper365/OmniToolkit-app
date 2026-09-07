/// FILE: lib/main.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:media_kit/media_kit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'core/data/asset_importer.dart';
import 'core/navigation/route_guard.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/share_target_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AppStartupGate()));
}

Future<void> initializeApplication() async {
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

  // Initialize media_kit backend for Windows/Linux audio playback
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    try {
      MediaKit.ensureInitialized();
      JustAudioMediaKit.ensureInitialized();
      debugPrint('[Audio] Media_kit initialized for ${Platform.isWindows ? 'Windows' : 'Linux'}');
    } catch (e) {
      debugPrint('[Audio] Media_kit initialization failed: $e');
    }
  }

  // Initialize just_audio background playback for Android/iOS
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      await JustAudioBackground.init(
        androidNotificationChannelId: 'com.omnitoolkit.channel.audio',
        androidNotificationChannelName: 'OmniToolkit Radio',
        androidNotificationOngoing: true,
      );
      debugPrint('[Audio] JustAudioBackground initialized for ${Platform.isAndroid ? 'Android' : 'iOS'}');
    } catch (e) {
      debugPrint('[Audio] JustAudioBackground initialization failed: $e');
    }
  }
}

class AppStartupGate extends ConsumerWidget {
  const AppStartupGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initFuture = ref.watch(appStartupProvider);
    return initFuture.when(
      data: (_) => const OmniToolkitApp(),
      loading: () => MaterialApp(
        title: 'OmniToolkit',
        home: Scaffold(
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
                  'Initializing OmniToolkit...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
      error: (error, stackTrace) => MaterialApp(
        title: 'OmniToolkit',
        home: Scaffold(
          appBar: AppBar(title: const Text('Initialization Error')),
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
                    'Failed to initialize app',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final appStartupProvider = FutureProvider<void>((ref) async {
  await initializeApplication();
});

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
        return generateProtectedRoutes(settings, ref);
      },
    );
  }
}
