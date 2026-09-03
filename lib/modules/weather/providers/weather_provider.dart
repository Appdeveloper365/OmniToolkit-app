import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/city_model.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

enum TemperatureUnit { celsius, fahrenheit }

final weatherServiceProvider = Provider<WeatherService>((ref) => WeatherService());

/// Temperature unit selection (Celsius vs Fahrenheit).
final temperatureUnitProvider = StateProvider<TemperatureUnit>((ref) => TemperatureUnit.celsius);

/// City currently selected by the user (defaults to New York City).
final selectedCityProvider = StateProvider<CityModel>((ref) {
  return const CityModel(
    name: 'New York',
    country: 'United States',
    admin1: 'New York',
    latitude: 40.7128,
    longitude: -74.0060,
    timezone: 'America/New_York',
  );
});

/// Debounced search results for the city search bar.
final citySearchQueryProvider = StateProvider<String>((ref) => '');

final citySearchResultsProvider = FutureProvider<List<CityModel>>((ref) async {
  final query = ref.watch(citySearchQueryProvider);
  if (query.trim().length < 2) return [];
  final service = ref.watch(weatherServiceProvider);
  return service.searchCities(query);
});

/// Weather for the currently selected city.
final currentWeatherProvider = FutureProvider<WeatherModel>((ref) async {
  final city = ref.watch(selectedCityProvider);
  final service = ref.watch(weatherServiceProvider);
  return service.getCurrentWeather(city);
});

/// Supplies the current time reactively when the weather view is built.
/// Ticks every second so clock updates live.
final clockTickProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});
