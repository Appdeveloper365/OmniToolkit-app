/// FILE: lib/modules/weather/widgets/dual_time_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../providers/weather_provider.dart';

/// Displays the selected city's current time.
class CityTimeWidget extends ConsumerWidget {
  const CityTimeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockTickProvider).valueOrNull ?? DateTime.now();
    final city = ref.watch(selectedCityProvider);

    DateTime cityTime;
    try {
      final location = tz.getLocation(city.timezone);
      cityTime = tz.TZDateTime.from(now.toUtc(), location);
    } catch (_) {
      cityTime = now;
    }

    final format12 = DateFormat('hh:mm:ss a');
    final format24 = DateFormat('HH:mm:ss');
    final dateFormat = DateFormat('EEE, MMM d yyyy');
    final dualTime =
        '${format12.format(cityTime)}  |  ${format24.format(cityTime)}';

    return _TimeCard(
      label: city.name,
      time: dualTime,
      date: dateFormat.format(cityTime),
    );
  }
}


class _TimeCard extends StatelessWidget {
  const _TimeCard({required this.label, required this.time, required this.date});

  final String label;
  final String time;
  final String date;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(time, style: Theme.of(context).textTheme.titleLarge),
            Text(date, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
