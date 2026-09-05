/// FILE: lib/modules/radio/providers/radio_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/station_model.dart';
import '../services/favorites_service.dart';
import '../services/radio_service.dart';
import '../services/stream_resolver_service.dart';

enum RadioStatus {
  stopped,
  buffering,
  live,
  offline,
  reconnecting,
}

class RadioState {
  const RadioState({
    this.currentStation,
    this.status = RadioStatus.stopped,
    this.statusText = '⚪ STOPPED',
    this.formatDetected,
    this.volume = 0.75,
    this.isMuted = false,
    this.errorMessage,
    this.reconnectCount = 0,
  });

  final StationModel? currentStation;
  final RadioStatus status;
  final String statusText;
  final String? formatDetected;
  final double volume;
  final bool isMuted;
  final String? errorMessage;
  final int reconnectCount;

  RadioState copyWith({
    StationModel? Function()? currentStation,
    RadioStatus? status,
    String? statusText,
    String? Function()? formatDetected,
    double? volume,
    bool? isMuted,
    String? Function()? errorMessage,
    int? reconnectCount,
  }) {
    return RadioState(
      currentStation: currentStation != null ? currentStation() : this.currentStation,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      formatDetected: formatDetected != null ? formatDetected() : this.formatDetected,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      reconnectCount: reconnectCount ?? this.reconnectCount,
    );
  }
}

final radioServiceProvider = Provider((ref) => RadioService());
final favoritesServiceProvider = Provider((ref) => FavoritesService());
final streamResolverServiceProvider = Provider((ref) => StreamResolverService());

final radioSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String?>((ref) => null);
final selectedGenreProvider = StateProvider<String?>((ref) => null);
final selectedCountryProvider = StateProvider<CountryInfo?>((ref) => null);

final stationListProvider = FutureProvider<List<StationModel>>((ref) async {
  final service = ref.watch(radioServiceProvider);
  final query = ref.watch(radioSearchQueryProvider);
  final category = ref.watch(selectedCategoryProvider);
  final genre = ref.watch(selectedGenreProvider);
  final country = ref.watch(selectedCountryProvider);

  if (query.trim().isNotEmpty) {
    return service.search(query);
  }
  if (country != null) {
    return service.byCountry(country.code);
  }
  if (genre != null) {
    return service.byCategory(genre);
  }
  if (category != null) {
    return service.byCategory(category);
  }
  return service.topStations();
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

final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
});

final currentStationProvider = StateProvider<StationModel?>((ref) {
  return ref.watch(radioStateProvider).currentStation;
});

final playerStateProvider = StreamProvider<PlayerState>((ref) {
  final player = ref.watch(audioPlayerProvider);
  return player.playerStateStream;
});

final radioStateProvider = NotifierProvider<RadioNotifier, RadioState>(RadioNotifier.new);

class RadioNotifier extends Notifier<RadioState> {
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  Timer? _reconnectTimer;
  Timer? _bufferTimeoutTimer;
  bool _isDisposed = false;
  Duration _lastPosition = Duration.zero;

  @override
  RadioState build() {
    _initVolume();
    _listenPlayer();
    ref.onDispose(() {
      _isDisposed = true;
      _playerStateSub?.cancel();
      _positionSub?.cancel();
      _reconnectTimer?.cancel();
      _bufferTimeoutTimer?.cancel();
    });
    return const RadioState(volume: 0.75, isMuted: false);
  }

  Future<void> _initVolume() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedVolume = prefs.getDouble('radio_volume') ?? 0.75;
      final savedMuted = prefs.getBool('radio_is_muted') ?? false;
      state = state.copyWith(volume: savedVolume, isMuted: savedMuted);

      debugPrint('[RadioLog] Startup Volume Initialization: audio.volume=$savedVolume, audio.muted=$savedMuted');

      final player = ref.read(audioPlayerProvider);
      await player.setVolume(savedMuted ? 0.0 : savedVolume);
    } catch (_) {}
  }

  void _listenPlayer() {
    final player = ref.read(audioPlayerProvider);
    _playerStateSub?.cancel();
    _playerStateSub = player.playerStateStream.listen((playerState) {
      if (_isDisposed) return;

      final playing = playerState.playing;
      final processingState = playerState.processingState;

      debugPrint('[RadioLog] Audio Element Diagnostics: readyState=${processingState.index}, playing=$playing, paused=${!playing}, volume=${player.volume}, muted=${state.isMuted}, position=${player.position.inSeconds}s');

      if (state.currentStation == null) {
        if (state.status != RadioStatus.stopped) {
          state = state.copyWith(
            status: RadioStatus.stopped,
            statusText: '⚪ STOPPED',
            errorMessage: () => null,
          );
        }
        return;
      }

      if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
        // Do NOT trigger buffer timeout while active playback is in progress
        // Only set status to BUFFERING if we weren't already LIVE, or if position stalls for > 15s
        if (state.status != RadioStatus.live) {
          debugPrint('[RadioLog] Status: BUFFERING');
          state = state.copyWith(
            status: RadioStatus.buffering,
            statusText: '🟡 BUFFERING',
          );
          _startBufferTimeout();
        } else {
          debugPrint('[RadioLog] Brief stream buffer glitch during live playback (maintaining LIVE state)');
        }
      } else if (playing && processingState == ProcessingState.ready) {
        _bufferTimeoutTimer?.cancel();
        debugPrint('[RadioLog] Status: PLAYING (● LIVE confirmed)');
        state = state.copyWith(
          status: RadioStatus.live,
          statusText: '🟢 LIVE',
          errorMessage: () => null,
          reconnectCount: 0,
        );
      } else if (processingState == ProcessingState.completed) {
        _bufferTimeoutTimer?.cancel();
        if (state.status == RadioStatus.live || state.status == RadioStatus.buffering) {
          _triggerReconnect('Stream completed unexpectedly.');
        } else {
          state = state.copyWith(
            status: RadioStatus.stopped,
            statusText: '⚪ STOPPED',
          );
        }
      } else if (!playing && processingState == ProcessingState.ready) {
        _bufferTimeoutTimer?.cancel();
        state = state.copyWith(
          status: RadioStatus.buffering,
          statusText: '⏸ PAUSED',
        );
      }
    });

    _positionSub?.cancel();
    _positionSub = player.positionStream.listen((pos) {
      if (_isDisposed) return;
      _lastPosition = pos;
      if (player.playing) {
        // Any time position advances, guarantee we cancel the buffer timeout!
        _bufferTimeoutTimer?.cancel();
        if (state.status != RadioStatus.live) {
          debugPrint('[RadioLog] Position advancing (${pos.inSeconds}s) -> confirming LIVE state');
          state = state.copyWith(
            status: RadioStatus.live,
            statusText: '🟢 LIVE',
            errorMessage: () => null,
            reconnectCount: 0,
          );
        }
      }
    });
  }

  void _startBufferTimeout() {
    _bufferTimeoutTimer?.cancel();
    _bufferTimeoutTimer = Timer(const Duration(seconds: 15), () {
      if (_isDisposed) return;
      // Only trip timeout if we never went LIVE or if position hasn't moved
      if (state.status == RadioStatus.buffering) {
        debugPrint('[RadioLog] FAILURE POINT: Buffering timed out after 15 seconds. CurrentPosition: ${_lastPosition.inSeconds}s');
        final player = ref.read(audioPlayerProvider);
        player.stop();

        String failReason;
        if (kIsWeb && StreamResolverService.isInsecureWebStream(state.currentStation?.streamUrl ?? '')) {
          failReason = 'Insecure radio stream blocked by browser policy.';
        } else if (kIsWeb) {
          failReason = 'Radio station stream unplayable in browser environment.';
        } else {
          failReason = 'Unable to start audio stream.';
        }

        state = state.copyWith(
          status: RadioStatus.offline,
          statusText: '🔴 OFFLINE',
          errorMessage: () => failReason,
        );
      }
    });
  }

  Future<void> playStation(StationModel station) async {
    debugPrint('[RadioLog] 1. Station selected: ${station.name}');
    debugPrint('[RadioLog] 2. Stream URL received: ${station.streamUrl}');

    final resolver = ref.read(streamResolverServiceProvider);
    final player = ref.read(audioPlayerProvider);

    _reconnectTimer?.cancel();
    _bufferTimeoutTimer?.cancel();
    _lastPosition = Duration.zero;

    state = state.copyWith(
      currentStation: () => station,
      status: RadioStatus.buffering,
      statusText: '🟡 BUFFERING',
      errorMessage: () => null,
      reconnectCount: 0,
    );

    // Validate stream URL, HTTPS, CORS, and playlists
    final validation = await resolver.resolveAndValidate(station.streamUrl);

    if (!validation.isValid) {
      debugPrint('[RadioLog] FAILURE POINT: URL Validation Failed - ${validation.errorMessage}');
      await player.stop();
      state = state.copyWith(
        status: RadioStatus.offline,
        statusText: '🔴 OFFLINE',
        errorMessage: () => validation.errorMessage ?? 'Unable to start audio stream.',
        formatDetected: () => validation.detectedFormat,
      );
      return;
    }

    debugPrint('[RadioLog] 3. URL validation passed: ${validation.resolvedUrl}');
    debugPrint('[RadioLog] Stream format detected: ${validation.detectedFormat}');

    state = state.copyWith(formatDetected: () => validation.detectedFormat);

    try {
      await player.stop();
      debugPrint('[RadioLog] 4. Connection established');

      // Note: On Web, omit custom headers to prevent CORS preflight blocking!
      await player.setAudioSource(
        AudioSource.uri(
          Uri.parse(validation.resolvedUrl),
          headers: kIsWeb ? null : const {'User-Agent': 'OmniToolkit/1.0'},
          tag: MediaItem(
            id: station.id,
            album: 'OmniToolkit Radio',
            title: station.name,
            artist: '${station.category}${station.country.isNotEmpty ? " • ${station.country}" : ""}',
            artUri: station.favicon != null ? Uri.tryParse(station.favicon!) : null,
          ),
        ),
      );

      debugPrint('[RadioLog] 5. Metadata loaded');
      debugPrint('[RadioLog] 6. Buffering started');
      _startBufferTimeout();

      final playFuture = player.play();
      await playFuture;
      debugPrint('[RadioLog] Play promise resolved successfully.');
    } catch (e, stackTrace) {
      debugPrint('[RadioLog] FAILURE POINT: Play promise rejected with exception.');
      debugPrint('[RadioLog] Error Name: ${e.runtimeType}');
      debugPrint('[RadioLog] Error Message: $e');
      debugPrint('[RadioLog] Stack Trace:\n$stackTrace');

      _bufferTimeoutTimer?.cancel();
      await player.stop();

      String errorMsg;
      final errString = e.toString().toLowerCase();

      if (errString.contains('notallowederror') || errString.contains('user gesture') || errString.contains('autoplay')) {
        errorMsg = 'Tap Play to enable audio.';
      } else if (StreamResolverService.isInsecureWebStream(station.streamUrl)) {
        errorMsg = 'Insecure radio stream blocked by browser policy.';
      } else if (kIsWeb && (errString.contains('xmlhttprequest') || errString.contains('cors') || errString.contains('format'))) {
        errorMsg = 'Radio station stream unplayable in browser environment.';
      } else {
        errorMsg = 'Unable to start audio stream.';
      }

      state = state.copyWith(
        status: RadioStatus.offline,
        statusText: '🔴 OFFLINE',
        errorMessage: () => failReasonText(errorMsg),
      );
    }
  }

  String failReasonText(String fallback) => fallback;

  Future<void> togglePlayPause() async {
    final player = ref.read(audioPlayerProvider);
    if (state.currentStation == null) return;

    if (player.playing) {
      debugPrint('[RadioLog] Playback paused by user.');
      await player.pause();
    } else {
      if (player.processingState == ProcessingState.idle) {
        await playStation(state.currentStation!);
      } else {
        try {
          await player.play();
        } catch (e, stackTrace) {
          debugPrint('[RadioLog] Play promise exception on resume: $e\n$stackTrace');
          state = state.copyWith(
            status: RadioStatus.offline,
            statusText: '🔴 OFFLINE',
            errorMessage: () => 'Tap Play to enable audio.',
          );
        }
      }
    }
  }

  Future<void> stop() async {
    debugPrint('[RadioLog] Playback stopped by user.');
    _reconnectTimer?.cancel();
    _bufferTimeoutTimer?.cancel();
    final player = ref.read(audioPlayerProvider);
    await player.stop();
    state = state.copyWith(
      currentStation: () => null,
      status: RadioStatus.stopped,
      statusText: '⚪ STOPPED',
      errorMessage: () => null,
    );
  }

  Future<void> setVolume(double newVolume) async {
    final clamped = newVolume.clamp(0.0, 1.0);
    state = state.copyWith(volume: clamped, isMuted: clamped == 0.0);

    final player = ref.read(audioPlayerProvider);
    await player.setVolume(state.isMuted ? 0.0 : clamped);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('radio_volume', clamped);
      await prefs.setBool('radio_is_muted', state.isMuted);
    } catch (_) {}
  }

  Future<void> toggleMute() async {
    final nextMute = !state.isMuted;
    state = state.copyWith(isMuted: nextMute);

    final player = ref.read(audioPlayerProvider);
    await player.setVolume(nextMute ? 0.0 : state.volume);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('radio_is_muted', nextMute);
    } catch (_) {}
  }

  void _triggerReconnect(String reason) {
    if (state.currentStation == null) return;

    final currentAttempts = state.reconnectCount;
    if (currentAttempts >= 3) {
      debugPrint('[RadioLog] FAILURE POINT: Reconnection failed after 3 attempts.');
      state = state.copyWith(
        status: RadioStatus.offline,
        statusText: '🔴 OFFLINE',
        errorMessage: () => 'Unable to start audio stream.',
      );
      return;
    }

    final nextAttempt = currentAttempts + 1;
    debugPrint('[RadioLog] Attempting reconnection ($nextAttempt/3)... Reason: $reason');

    state = state.copyWith(
      status: RadioStatus.reconnecting,
      statusText: '🟡 RECONNECTING ($nextAttempt/3)',
      reconnectCount: nextAttempt,
      errorMessage: () => 'Attempting reconnection...',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (state.currentStation != null && state.status == RadioStatus.reconnecting) {
        playStation(state.currentStation!);
      }
    });
  }

  Future<void> playNextFavorite() async {
    final favorites = ref.read(favoritesProvider).valueOrNull ?? [];
    if (favorites.isEmpty) return;
    if (state.currentStation == null) {
      await playStation(favorites.first);
      return;
    }
    final currentIndex = favorites.indexWhere((s) => s.id == state.currentStation!.id);
    final nextIndex = (currentIndex + 1) % favorites.length;
    await playStation(favorites[nextIndex]);
  }

  Future<void> playPreviousFavorite() async {
    final favorites = ref.read(favoritesProvider).valueOrNull ?? [];
    if (favorites.isEmpty) return;
    if (state.currentStation == null) {
      await playStation(favorites.last);
      return;
    }
    final currentIndex = favorites.indexWhere((s) => s.id == state.currentStation!.id);
    final prevIndex = currentIndex <= 0 ? favorites.length - 1 : currentIndex - 1;
    await playStation(favorites[prevIndex]);
  }
}

class RadioPlaybackController {
  RadioPlaybackController(this.ref);
  final Ref ref;

  Future<void> play(StationModel station) async {
    await ref.read(radioStateProvider.notifier).playStation(station);
  }

  Future<void> togglePlayPause() async {
    await ref.read(radioStateProvider.notifier).togglePlayPause();
  }

  Future<void> stop() async {
    await ref.read(radioStateProvider.notifier).stop();
  }

  Future<void> setVolume(double vol) async {
    await ref.read(radioStateProvider.notifier).setVolume(vol);
  }

  Future<void> toggleMute() async {
    await ref.read(radioStateProvider.notifier).toggleMute();
  }

  Future<void> nextFavorite() async {
    await ref.read(radioStateProvider.notifier).playNextFavorite();
  }

  Future<void> previousFavorite() async {
    await ref.read(radioStateProvider.notifier).playPreviousFavorite();
  }
}

final radioPlaybackControllerProvider = Provider((ref) => RadioPlaybackController(ref));
