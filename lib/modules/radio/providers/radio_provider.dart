/// FILE: lib/modules/radio/providers/radio_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../models/station_model.dart';
import '../services/favorites_service.dart';
import '../services/radio_service.dart';

final radioServiceProvider = Provider((ref) => RadioService());
final favoritesServiceProvider = Provider((ref) => FavoritesService());

final radioSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final stationListProvider = FutureProvider<List<StationModel>>((ref) async {
  final service = ref.watch(radioServiceProvider);
  final query = ref.watch(radioSearchQueryProvider);
  final category = ref.watch(selectedCategoryProvider);

  final stations = query.trim().isNotEmpty ? await service.search(query)
      : category != null ? await service.byCategory(category) : await service.topStations();
  if (category == null) return stations;
  return stations.where((s) => s.category.toLowerCase().contains(category.toLowerCase()) ||
      s.name.toLowerCase().contains(query.toLowerCase())).toList();
});

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<StationModel>>(FavoritesNotifier.new);

class FavoritesNotifier extends AsyncNotifier<List<StationModel>> {
  @override
  Future<List<StationModel>> build() {
    return ref.read(favoritesServiceProvider).loadFavorites();
  }

  Future<void> toggle(StationModel station) async {
    final current = state.valueOrNull ?? [];
    final exists = current.any((s) => s.id == station.id);
    final updated = exists
        ? current.where((s) => s.id != station.id).toList()
        : [...current, station];
    state = AsyncData(updated);
    await ref.read(favoritesServiceProvider).saveFavorites(updated);
  }

  bool isFavorite(String id) => (state.valueOrNull ?? []).any((s) => s.id == id);
}

/// Global just_audio player shared across the radio screen for background
/// playback support (registered via JustAudioBackground in main.dart).
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
});

final currentStationProvider = StateProvider<StationModel?>((ref) => null);

final playerStateProvider = StreamProvider<PlayerState>((ref) {
  final player = ref.watch(audioPlayerProvider);
  return player.playerStateStream;
});

class RadioPlaybackController {
  RadioPlaybackController(this.ref);
  final Ref ref;

  Future<void> play(StationModel station) async {
    final player = ref.read(audioPlayerProvider);
    ref.read(currentStationProvider.notifier).state = station;
    await player.setAudioSource(
      AudioSource.uri(
        Uri.parse(station.streamUrl),
        headers: const {
          'User-Agent': 'OmniToolkit/1.0',
          'Accept': '*/*',
        },
        tag: MediaItem(
          id: station.id,
          album: 'OmniToolkit Radio',
          title: station.name,
        ),
      ),
    );
    await player.play();
  }

  Future<void> togglePlayPause() async {
    final player = ref.read(audioPlayerProvider);
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  Future<void> stop() async {
    final player = ref.read(audioPlayerProvider);
    await player.stop();
    ref.read(currentStationProvider.notifier).state = null;
  }
}

final radioPlaybackControllerProvider = Provider((ref) => RadioPlaybackController(ref));
