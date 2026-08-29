/// FILE: lib/modules/weather/models/weather_model.dart

/// Current weather conditions returned by the Open-Meteo forecast API.
class WeatherModel {
  const WeatherModel({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.sunrise,
    required this.sunset,
    required this.observedAt,
  });

  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime observedAt;

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;
    return WeatherModel(
      temperature: (current['temperature_2m'] as num).toDouble(),
      apparentTemperature: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      sunrise: DateTime.parse((daily['sunrise'] as List).first as String),
      sunset: DateTime.parse((daily['sunset'] as List).first as String),
      observedAt: DateTime.parse(current['time'] as String),
    );
  }

  /// Human readable summary derived from the WMO weather code.
  String get description {
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode <= 2) return 'Partly cloudy';
    if (weatherCode == 3) return 'Overcast';
    if (weatherCode <= 48) return 'Foggy';
    if (weatherCode <= 57) return 'Drizzle';
    if (weatherCode <= 67) return 'Rain';
    if (weatherCode <= 77) return 'Snow';
    if (weatherCode <= 82) return 'Rain showers';
    if (weatherCode <= 86) return 'Snow showers';
    if (weatherCode <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  IconDataKey get iconKey {
    if (weatherCode == 0) return IconDataKey.clear;
    if (weatherCode <= 3) return IconDataKey.cloud;
    if (weatherCode <= 48) return IconDataKey.fog;
    if (weatherCode <= 67 || (weatherCode >= 80 && weatherCode <= 82)) {
      return IconDataKey.rain;
    }
    if (weatherCode <= 77 || (weatherCode >= 85 && weatherCode <= 86)) {
      return IconDataKey.snow;
    }
    return IconDataKey.storm;
  }
}

enum IconDataKey { clear, cloud, fog, rain, snow, storm }
