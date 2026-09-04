import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'core/navigation/main_navigation.dart';
import 'core/theme/app_theme.dart';
import 'core/data/asset_importer.dart';
import 'screens/share_target_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    tz_data.initializeTimeZones();
    await AssetImporter.importFirstLaunch();

    // Initialize media_kit backend for Windows/Linux audio playback
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
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
    // Don't let startup data/plugin failures prevent the window from showing.
    debugPrint('Startup initialization failed: $error\n$stackTrace');
  }
  runApp(const ProviderScope(child: OmniToolkitApp()));
}

class OmniToolkitApp extends StatelessWidget {
  const OmniToolkitApp({super.key});

  @override
  Widget build(BuildContext context) {
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

        // Default home root route
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MainNavigation(),
        );
      },
    );
  }
}
