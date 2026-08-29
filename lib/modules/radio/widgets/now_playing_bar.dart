/// FILE: lib/modules/radio/widgets/now_playing_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../providers/radio_provider.dart';

/// Persistent mini-player shown above the bottom navigation while a
/// station is streaming (audio-only, supports background playback).
class NowPlayingBar extends ConsumerWidget {
  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final station = ref.watch(currentStationProvider);
    final playerStateAsync = ref.watch(playerStateProvider);
    final controller = ref.read(radioPlaybackControllerProvider);

    if (station == null) return const SizedBox.shrink();

    final isPlaying = playerStateAsync.valueOrNull?.playing ?? false;
    final processingState = playerStateAsync.valueOrNull?.processingState;

    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        leading: const Icon(Icons.radio),
        title: Text(station.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering
            ? 'Buffering...'
            : 'Streaming'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: controller.togglePlayPause,
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: controller.stop,
            ),
          ],
        ),
      ),
    );
  }
}
