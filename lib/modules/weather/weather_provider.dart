/// FILE: lib/modules/weather/weather_provider.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'weather_service.dart';

/// UI states of the live weather box.
sealed class WeatherUiState {
  const WeatherUiState();
}

/// First fetch in flight ("Detecting...").
class WeatherLoading extends WeatherUiState {
  const WeatherLoading();
}

/// Live data available.
class WeatherOk extends WeatherUiState {
  const WeatherOk(this.snapshot);
  final WeatherSnapshot snapshot;
}

/// WEATHERAPI_KEY is not configured on the backend yet: show the safe
/// placeholder preview instead of real values.
class WeatherPreview extends WeatherUiState {
  const WeatherPreview();
}

/// The lookup failed (offline, upstream error): show a retry affordance.
class WeatherOffline extends WeatherUiState {
  const WeatherOffline();
}

final weatherProvider =
    StateNotifierProvider<WeatherNotifier, WeatherUiState>(
        (ref) => WeatherNotifier());

/// Fetches current weather on creation and re-fetches every 15 minutes.
class WeatherNotifier extends StateNotifier<WeatherUiState> {
  WeatherNotifier() : super(const WeatherLoading()) {
    _start();
  }

  /// Test seam: a notifier pinned to [state] that never fetches.
  @visibleForTesting
  WeatherNotifier.fixed(super.fixedState);

  Timer? _timer;

  void _start() {
    _refresh();
    _timer = Timer.periodic(
      WeatherService.refreshInterval,
      (_) => _refresh(),
    );
  }

  /// Immediate refresh (retry tap, or pull-to-refresh style affordances).
  Future<void> refreshNow() => _refresh();

  Future<void> _refresh() async {
    try {
      final snapshot = await WeatherService.fetch();
      state = WeatherOk(snapshot);
    } on WeatherNotConfiguredException {
      state = const WeatherPreview();
    } catch (_) {
      state = const WeatherOffline();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
