/// FILE: lib/modules/weather/services/weather_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/city_model.dart';
import '../models/weather_model.dart';

/// Talks to the free, keyless Open-Meteo geocoding + forecast APIs.
class WeatherService {
  static const _geocodeBase = 'https://geocoding-api.open-meteo.com/v1/search';
  static const _forecastBase = 'https://api.open-meteo.com/v1/forecast';

  Future<List<CityModel>> searchCities(String query) async {
    if (query.trim().isEmpty) return [];
    final uri = Uri.parse(_geocodeBase).replace(queryParameters: {
      'name': query,
      'count': '10',
      'language': 'en',
      'format': 'json',
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to search cities (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>?;
    if (results == null) return [];
    return results
        .map((e) => CityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WeatherModel> getCurrentWeather(CityModel city) async {
    final uri = Uri.parse(_forecastBase).replace(queryParameters: {
      'latitude': city.latitude.toString(),
      'longitude': city.longitude.toString(),
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,'
          'weather_code,wind_speed_10m',
      'daily': 'sunrise,sunset',
      'timezone': city.timezone,
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch weather (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return WeatherModel.fromJson(body);
  }
}
