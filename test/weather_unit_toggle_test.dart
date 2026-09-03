import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/modules/weather/models/weather_model.dart';
import 'package:omnitoolkit/modules/weather/providers/weather_provider.dart';
import 'package:omnitoolkit/modules/weather/widgets/weather_info_card.dart';

void main() {
  testWidgets('WeatherInfoCard toggles between Celsius and Fahrenheit', (tester) async {
    final weather = WeatherModel(
      temperature: 20.0,
      apparentTemperature: 18.0,
      humidity: 50,
      windSpeed: 10.0,
      weatherCode: 0,
      sunrise: DateTime.now(),
      sunset: DateTime.now(),
      observedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: WeatherInfoCard(weather: weather),
          ),
        ),
      ),
    );

    // Initial temperature in Celsius
    expect(find.text('20.0°C'), findsOneWidget);
    expect(find.text('Feels like 18.0°C'), findsOneWidget);

    // Toggle unit provider to Fahrenheit
    final element = tester.element(find.byType(WeatherInfoCard));
    final container = ProviderScope.containerOf(element);
    container.read(temperatureUnitProvider.notifier).state = TemperatureUnit.fahrenheit;
    await tester.pump();

    // Temperature converted to Fahrenheit (20°C = 68°F, 18°C = 64.4°F)
    expect(find.text('68.0°F'), findsOneWidget);
    expect(find.text('Feels like 64.4°F'), findsOneWidget);
  });
}
