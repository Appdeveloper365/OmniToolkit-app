/// FILE: lib/main.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:media_kit/media_kit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'core/data/asset_importer.dart';
import 'core/navigation/route_guard.dart';
import 'core/theme/app_theme.dart';
import 'screens/share_target_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    tz_data.initializeTimeZones();
    await AssetImporter.importFirstLaunch();

    // Initialize media_kit backend for Windows/Linux audio playback
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      MediaKit.ensureInitialized();
      JustAudioMediaKit.ensureInitialized();
    }

    // Initialize just_audio background playback for Android/iOS
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await JustAudioBackground.init(
        androidNotificationChannelId: 'com.omnitoolkit.channel.audio',
        androidNotificationChannelName: 'OmniToolkit Radio',
        androidNotificationOngoing: true,
      );
    }
  } catch (error, stackTrace) {
    debugPrint('Startup initialization failed: $error\n$stackTrace');
  }
  runApp(const ProviderScope(child: OmniToolkitApp()));
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
        return generateProtectedRoutes(settings, ref);
      },
    );
  }
}
