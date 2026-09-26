import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Weather service using MET Norway API (free, no signup)
class WeatherService {
  static const String _baseUrl = 'https://api.met.no/weatherapi/locationforecast/2.0/compact';
  
  /// User-Agent header - required by MET Norway
  /// Replace with your actual app details
  static const String _userAgent = 'OmniToolkit/1.0 (https://yourcalendar.app; support@yourcalendar.app)';
  
  static const int _cacheTTL = 45 * 60 * 1000; // 45 minutes
  static const String _cacheKey = 'weather_cache';

  /// Fetch weather data from MET Norway
  static Future<WeatherData?> fetchWeather({
    required double latitude,
    required double longitude,
    double? altitude,
  }) async {
    // Truncate to max 4 decimal places
    final lat = (latitude * 10000).round() / 10000;
    final lon = (longitude * 10000).round() / 10000;

    // Check cache first
    final cached = await _getCachedWeather(lat, lon);
    if (cached != null && DateTime.now().difference(cached.timestamp) < Duration(milliseconds: _cacheTTL)) {
      return cached.data;
    }

    // Build URL
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        if (altitude != null) 'altitude': altitude.round().toString(),
      },
    );

    try {
      final response = await http
          .get(uri, headers: {
            'User-Agent': _userAgent,
            'Accept': 'application/json',
          })
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 403) {
        throw Exception('Access blocked: Check User-Agent');
      }
      if (response.statusCode == 429) {
        throw Exception('Rate limited');
      }
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final json = jsonDecode(response.body);
      final weatherData = WeatherData.fromJson(json);
      await _cacheWeather(lat, lon, weatherData);
      return weatherData;
    } catch (e) {
      final stale = await _getCachedWeather(lat, lon);
      if (stale != null) {
        return stale.data;
      }
      rethrow;
    }
  }

  /// Get cached weather data
  static Future<WeatherCacheEntry?> _getCachedWeather(double lat, double lon) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_cacheKey${lat.toStringAsFixed(4)}_${lon.toStringAsFixed(4)}';
      final cached = prefs.getString(key);
      if (cached == null) return null;
      
      final Map<String, dynamic> data = jsonDecode(cached);
      return WeatherCacheEntry(
        data: WeatherData.fromJson(data['weather']),
        timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp']),
      );
    } catch (e) {
      return null;
    }
  }

  /// Cache weather data
  static Future<void> _cacheWeather(double lat, double lon, WeatherData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_cacheKey${lat.toStringAsFixed(4)}_${lon.toStringAsFixed(4)}';
      final cacheData = {
        'weather': data.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await prefs.setString(key, jsonEncode(cacheData));
    } catch (e) {
      // Silently fail
    }
  }

  /// Clear all cached weather data
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_cacheKey));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      // Silently fail
    }
  }
}

class WeatherCacheEntry {
  final WeatherData data;
  final DateTime timestamp;
  
  WeatherCacheEntry({required this.data, required this.timestamp});
}

class WeatherData {
  final double? temperature;
  final String? condition;
  final String? symbolCode;
  final int? humidity;
  final double? windSpeed;
  final double? precipitationNextHour;
  final String? alert;
  final String? updatedTime;
  final String provider;

  WeatherData({
    this.temperature,
    this.condition,
    this.symbolCode,
    this.humidity,
    this.windSpeed,
    this.precipitationNextHour,
    this.alert,
    this.updatedTime,
    this.provider = 'MET Norway',
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final timeseries = json['properties']?['timeseries'] as List? ?? [];
    if (timeseries.isEmpty) {
      return WeatherData(provider: 'MET Norway');
    }

    final current = timeseries[0] as Map<String, dynamic>;
    final instant = current['data']?['instant']?['details'] ?? {};
    final next1h = current['data']?['next_1_hours'] ?? {};
    final next6h = current['data']?['next_6_hours'] ?? {};

    final temp = instant['air_temperature'] as double?;
    final humidity = instant['relative_humidity'] as int?;
    final windSpeed = instant['wind_speed'] as double?;
    final cloud = instant['cloud_area_fraction'] as double?;

    final symbol = next1h['summary']?['symbol_code'] 
        ?? next6h['summary']?['symbol_code'];

    final precip1h = next1h['details']?['precipitation_amount'] as double? ?? 0;
    final condition = _mapSymbolToCondition(symbol);

    final alerts = _generateAlerts(
      current: current,
      timeseries: timeseries,
      symbol: symbol,
      temp: temp,
      precip1h: precip1h,
    );

    return WeatherData(
      temperature: temp,
      condition: condition,
      symbolCode: symbol,
      humidity: humidity,
      windSpeed: windSpeed,
      precipitationNextHour: precip1h,
      alert: alerts.isNotEmpty ? alerts.join(' · ') : temp != null ? '${temp.round()}°' : condition,
      updatedTime: current['time'],
      provider: 'MET Norway',
    );
  }

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'condition': condition,
    'symbolCode': symbolCode,
    'humidity': humidity,
    'windSpeed': windSpeed,
    'precipitationNextHour': precipitationNextHour,
    'alert': alert,
    'updatedTime': updatedTime,
    'provider': provider,
  };

  static String? _mapSymbolToCondition(String? symbol) {
    if (symbol == null) return 'Unknown';
    const conditionMap = {
      'clearsky_day': 'Sunny',
      'clearsky_night': 'Clear',
      'fair_day': 'Fair',
      'fair_night': 'Fair',
      'partlycloudy_day': 'Partly cloudy',
      'partlycloudy_night': 'Partly cloudy',
      'cloudy': 'Cloudy',
      'rain': 'Rain',
      'lightrain': 'Light rain',
      'heavyrain': 'Heavy rain',
      'sleet': 'Sleet',
      'snow': 'Snow',
      'lightsnow': 'Light snow',
      'fog': 'Fog',
    };
    return conditionMap[symbol] ?? symbol.replaceAll('_', ' ');
  }

  static List<String> _generateAlerts({
    required Map<String, dynamic> current,
    required List<dynamic> timeseries,
    required String? symbol,
    required double? temp,
    required double precip1h,
  }) {
    final alerts = <String>[];

    if (precip1h > 2) {
      alerts.add('Heavy rain expected in next hour');
    } else if (symbol != null && (symbol.contains('rain') || symbol.contains('sleet'))) {
      alerts.add('Rain expected in next hour');
    } else if (precip1h > 0.1) {
      alerts.add('Precipitation expected soon');
    }

    final later = _getEntryAtOffset(timeseries, 1);
    if (later != null) {
      final laterTemp = later['data']?['instant']?['details']?['air_temperature'] as double?;
      if (laterTemp != null && temp != null) {
        final delta = laterTemp - temp;
        if (delta >= 1.5) alerts.add('Temperature rising');
        else if (delta <= -1.5) alerts.add('Temperature falling');
      }
    }

    final laterSymbol = _getSymbolAtOffset(timeseries, 1) 
        ?? _getSymbolAtOffset(timeseries, 2);
    if (laterSymbol != null) {
      if (laterSymbol.contains('clearsky') || laterSymbol.contains('fair')) {
        if (symbol == null || (!symbol!.contains('clearsky') && !symbol!.contains('fair'))) {
          alerts.add('Sunny conditions ahead');
        }
      } else if (laterSymbol == 'cloudy') {
        if (symbol == null || !symbol!.contains('cloudy')) {
          alerts.add('Cloudier conditions ahead');
        }
      } else if (laterSymbol.contains('rain') || laterSymbol.contains('snow')) {
        alerts.add('Wet weather ahead');
      }
    }

    if (alerts.isEmpty) {
      if (symbol != null && (symbol.contains('clearsky') || symbol.contains('fair'))) {
        alerts.add('Sunny conditions');
      } else if (symbol != null && symbol.contains('cloudy')) {
        alerts.add('Cloudy conditions');
      } else if (precip1h == 0) {
        alerts.add('No precipitation expected soon');
      }
    }

    return alerts.take(2).toList();
  }

  static double? _getTemperatureAtOffset(List<dynamic> timeseries, int offset) {
    if (offset >= timeseries.length) return null;
    return timeseries[offset]['data']?['instant']?['details']?['air_temperature'] as double?;
  }

  static Map<String, dynamic>? _getEntryAtOffset(List<dynamic> timeseries, int offset) {
    if (offset >= timeseries.length) return null;
    return timeseries[offset] as Map<String, dynamic>?;
  }

  static String? _getSymbolAtOffset(List<dynamic> timeseries, int offset) {
    if (offset >= timeseries.length) return null;
    final entry = timeseries[offset];
    return entry['data']?['next_1_hours']?['summary']?['symbol_code'] 
        ?? entry['data']?['next_6_hours']?['summary']?['symbol_code'];
  }
}
