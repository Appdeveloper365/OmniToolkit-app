import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/modules/weather/weather_provider.dart';
import 'package:omnitoolkit/modules/weather/weather_service.dart';
import 'package:omnitoolkit/modules/weather/widgets/weather_widget.dart';

void main() {
  test('WeatherSnapshot.fromData maps the backend payload', () {
    final snapshot = WeatherSnapshot.fromData({
      'location': {'name': 'London', 'region': 'City of London', 'country': 'UK'},
      'current': {
        'temp_c': 21.4,
        'is_day': true,
        'condition': {
          'text': 'Sunny',
          'icon': '//cdn.weatherapi.com/weather/64x64/day/113.png',
          'code': 1000,
        },
      },
    });

    expect(snapshot.locationName, 'London');
    expect(snapshot.tempC, 21.4);
    expect(snapshot.tempLabel, '21°C');
    expect(snapshot.conditionText, 'Sunny');
    expect(snapshot.iconUrl, 'https://cdn.weatherapi.com/weather/64x64/day/113.png');
    expect(snapshot.isDay, isTrue);
  });

  test('WeatherSnapshot.fromData tolerates missing fields', () {
    final snapshot = WeatherSnapshot.fromData({});
    expect(snapshot.locationName, '');
    expect(snapshot.tempC, isNull);
    expect(snapshot.tempLabel, '--°C');
    expect(snapshot.iconUrl, '');
  });

  testWidgets('preview state shows the placeholder before the API key is set', (tester) async {
    await _pumpWeather(tester, const WeatherPreview());

    expect(find.text('LOCAL SPACE'), findsOneWidget);
    expect(find.text('21°C'), findsOneWidget);
    expect(find.text('Sunny intervals'), findsOneWidget);
    expect(find.text('Weather data by WeatherAPI.com'), findsOneWidget);
  });

  testWidgets('ok state shows live location, temperature and condition', (tester) async {
    const snapshot = WeatherSnapshot(
      locationName: 'London',
      tempC: 12.6,
      conditionText: 'Light rain',
      conditionIconPath: '',
      isDay: false,
    );
    await _pumpWeather(tester, const WeatherOk(snapshot));

    expect(find.text('LONDON'), findsOneWidget);
    expect(find.text('13°C'), findsOneWidget);
    expect(find.text('Light rain'), findsOneWidget);
    expect(find.text('Weather data by WeatherAPI.com'), findsOneWidget);
  });

  testWidgets('offline state offers tap-to-retry', (tester) async {
    await _pumpWeather(tester, const WeatherOffline());

    expect(find.text('OFFLINE'), findsOneWidget);
    expect(find.text('Weather unavailable - tap to retry'), findsOneWidget);

    // Tapping retries the fetch; with no Firebase app in the test binding
    // the service fails and the box stays in the offline state.
    await tester.tap(find.text('Weather unavailable - tap to retry'));
    await tester.pump();
    expect(find.text('OFFLINE'), findsOneWidget);
  });

  testWidgets('loading state shows the detection placeholder', (tester) async {
    await _pumpWeather(tester, const WeatherLoading());

    expect(find.text('DETECTING...'), findsOneWidget);
    expect(find.text('--°C'), findsOneWidget);
    expect(find.text('Locating radar...'), findsOneWidget);
  });
}

Future<void> _pumpWeather(WidgetTester tester, WeatherUiState state) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        weatherProvider.overrideWith((ref) => WeatherNotifier.fixed(state)),
      ],
      child: const MaterialApp(
        home: Scaffold(body: Center(child: SizedBox(width: 240, child: WeatherWidget()))),
      ),
    ),
  );
  // One frame only: the pulse dot animation repeats forever, so
  // pumpAndSettle would never settle.
  await tester.pump(const Duration(milliseconds: 50));
}
