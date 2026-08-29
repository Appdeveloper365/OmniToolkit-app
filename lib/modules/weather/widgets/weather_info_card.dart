/// FILE: lib/modules/weather/widgets/weather_info_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/weather_model.dart';

/// Displays temperature, humidity, wind, sunrise and sunset details.
class WeatherInfoCard extends ConsumerWidget {
  const WeatherInfoCard({super.key, required this.weather});

  final WeatherModel weather;

  IconData get _icon {
    switch (weather.iconKey) {
      case IconDataKey.clear:
        return Icons.wb_sunny;
      case IconDataKey.cloud:
        return Icons.cloud_outlined;
      case IconDataKey.fog:
        return Icons.foggy;
      case IconDataKey.rain:
        return Icons.water_drop_outlined;
      case IconDataKey.snow:
        return Icons.ac_unit;
      case IconDataKey.storm:
        return Icons.thunderstorm_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final format12 = DateFormat('hh:mm a');
    final format24 = DateFormat('HH:mm');
    String dualTime(DateTime dateTime) =>
        '${format12.format(dateTime)}  |  ${format24.format(dateTime)}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(_icon, size: 48),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperature.toStringAsFixed(1)}°C',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(weather.description),
                    Text('Feels like ${weather.apparentTemperature.toStringAsFixed(1)}°C'),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _Stat(icon: Icons.water_drop, label: 'Humidity', value: '${weather.humidity}%'),
                _Stat(icon: Icons.air, label: 'Wind', value: '${weather.windSpeed.toStringAsFixed(1)} km/h'),
                _Stat(icon: Icons.wb_twilight, label: 'Sunrise', value: dualTime(weather.sunrise)),
                _Stat(icon: Icons.nights_stay, label: 'Sunset', value: dualTime(weather.sunset)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                Text(value, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
