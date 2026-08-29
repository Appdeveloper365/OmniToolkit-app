/// FILE: lib/modules/weather/screens/weather_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/weather_provider.dart';
import '../widgets/dual_time_widget.dart';
import '../widgets/weather_info_card.dart';
import '../widgets/weather_search_bar.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(selectedCityProvider);
    final weatherAsync = ref.watch(currentWeatherProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(currentWeatherProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const WeatherSearchBar(),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.place, size: 20),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    city.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const CityTimeWidget(),
            const SizedBox(height: 16),
            weatherAsync.when(
              data: (weather) => WeatherInfoCard(weather: weather),
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Failed to load weather: $err'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
