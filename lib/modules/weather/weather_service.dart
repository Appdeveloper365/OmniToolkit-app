/// FILE: lib/modules/weather/weather_service.dart
import 'package:cloud_functions/cloud_functions.dart';

import 'browser_geolocation.dart';

/// Immutable current-weather snapshot returned by the getWeather callable.
class WeatherSnapshot {
  const WeatherSnapshot({
    required this.locationName,
    required this.tempC,
    required this.conditionText,
    required this.conditionIconPath,
    required this.isDay,
  });

  final String locationName;
  final double? tempC;
  final String conditionText;

  /// WeatherAPI condition icon path, e.g.
  /// `//cdn.weatherapi.com/weather/64x64/day/113.png`.
  final String conditionIconPath;
  final bool isDay;

  String get tempLabel => tempC == null ? '--°C' : '${tempC!.round()}°C';
  String get iconUrl =>
      conditionIconPath.isEmpty ? '' : 'https:$conditionIconPath';

  factory WeatherSnapshot.fromData(Map<String, dynamic> data) {
    final location = (data['location'] as Map?) ?? const {};
    final current = (data['current'] as Map?) ?? const {};
    final condition = (current['condition'] as Map?) ?? const {};
    final temp = current['temp_c'];
    return WeatherSnapshot(
      locationName: (location['name'] as String? ?? '').trim(),
      tempC: temp is num ? temp.toDouble() : null,
      conditionText: (condition['text'] as String? ?? '').trim(),
      conditionIconPath: (condition['icon'] as String? ?? '').trim(),
      isDay: current['is_day'] == true || current['is_day'] == 1,
    );
  }
}

/// Thrown when the backend proxy reports that WEATHERAPI_KEY has not been
/// configured yet. The UI answers with the placeholder preview.
class WeatherNotConfiguredException implements Exception {
  const WeatherNotConfiguredException();
}

/// Fetches the current weather for the user's location. The WeatherAPI.com
/// key never ships with the app (public PWA) -- the getWeather Firebase
/// callable attaches it server-side.
class WeatherService {
  const WeatherService._();

  /// Fallback city when geolocation is denied, unsupported, or stalls.
  static const defaultLocation = 'New York';

  /// Auto-refresh window for the live weather box (comfortably inside
  /// WeatherAPI's free tier).
  static const refreshInterval = Duration(minutes: 15);

  static Future<WeatherSnapshot> fetch() async {
    var query = defaultLocation;
    final position = await browserGeolocationPosition();
    if (position != null) {
      query = '${position.latitude},${position.longitude}';
    }

    final result = await FirebaseFunctions.instance
        .httpsCallable('getWeather')
        .call({'q': query});

    final data = result.data;
    if (data is! Map || data['configured'] != true) {
      throw const WeatherNotConfiguredException();
    }
    return WeatherSnapshot.fromData(Map<String, dynamic>.from(data));
  }
}
