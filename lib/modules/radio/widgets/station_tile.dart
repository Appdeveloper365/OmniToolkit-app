/// FILE: lib/modules/radio/widgets/station_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/station_model.dart';
import '../providers/radio_provider.dart';

class StationTile extends ConsumerWidget {
  const StationTile({super.key, required this.station});

  final StationModel station;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.valueOrNull?.any((s) => s.id == station.id) ?? false;
    final currentStation = ref.watch(currentStationProvider);
    final isPlaying = currentStation?.id == station.id;
    final controller = ref.read(radioPlaybackControllerProvider);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: station.favicon != null ? NetworkImage(station.favicon!) : null,
          child: station.favicon == null ? const Icon(Icons.radio) : null,
        ),
        title: Text(station.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${station.category} • ${station.country}', maxLines: 1, overflow: TextOverflow.ellipsis),
        selected: isPlaying,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () => ref.read(favoritesProvider.notifier).toggle(station),
            ),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
              onPressed: () {
                if (isPlaying) {
                  controller.togglePlayPause();
                } else {
                  controller.play(station);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
