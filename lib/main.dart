import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'core/navigation/main_navigation.dart';
import 'core/theme/app_theme.dart';
import 'core/data/asset_importer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    tz_data.initializeTimeZones();
    await AssetImporter.importFirstLaunch();

    // Initialize media_kit backend for Windows/Linux audio playback
    if (Platform.isWindows || Platform.isLinux) {
      JustAudioMediaKit.ensureInitialized();
    }

    // Initialize just_audio background playback for Android/iOS
    if (Platform.isAndroid || Platform.isIOS) {
      await JustAudioBackground.init(
        androidNotificationChannelId: 'com.omnitoolkit.channel.audio',
        androidNotificationChannelName: 'OmniToolkit Radio',
        androidNotificationOngoing: true,
      );
    }
  } catch (error) {
    // Don't let startup data/plugin failures prevent the window from showing.
    debugPrint('Startup initialization failed: $error');
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
      home: const MainNavigation(),
    );
  }
}
