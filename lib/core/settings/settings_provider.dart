import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

class AppSettings {
  const AppSettings({this.use24HourFormat = false, this.autoSaveClips = true});
  final bool use24HourFormat;
  final bool autoSaveClips;
  AppSettings copyWith({bool? use24HourFormat, bool? autoSaveClips}) =>
      AppSettings(use24HourFormat: use24HourFormat ?? this.use24HourFormat,
          autoSaveClips: autoSaveClips ?? this.autoSaveClips);
}

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  late SharedPreferences _prefs;
  @override
  Future<AppSettings> build() async {
    _prefs = await SharedPreferences.getInstance();
    return AppSettings(
      use24HourFormat: _prefs.getBool('use24HourFormat') ?? false,
      autoSaveClips: _prefs.getBool('autoSaveClips') ?? true,
    );
  }
  Future<void> updateSettings({bool? use24HourFormat, bool? autoSaveClips}) async {
    final next = (state.valueOrNull ?? const AppSettings()).copyWith(
      use24HourFormat: use24HourFormat, autoSaveClips: autoSaveClips);
    state = AsyncData(next);
    if (use24HourFormat != null) await _prefs.setBool('use24HourFormat', use24HourFormat);
    if (autoSaveClips != null) await _prefs.setBool('autoSaveClips', autoSaveClips);
  }
}
