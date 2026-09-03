import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/station_model.dart';
import 'radio_db_service.dart';

/// Client for the free, keyless Radio Browser API used to search stations
/// and browse them by category (genre tag).
class RadioService {
  RadioService({RadioDbService? radioDbService})
      : _radioDbService = radioDbService ?? RadioDbService();

  final RadioDbService _radioDbService;

  static const _hosts = [
    'de1.api.radio-browser.info',
    'fi1.api.radio-browser.info',
    'nl1.api.radio-browser.info',
    'at1.api.radio-browser.info',
  ];

  static const categories = ['News', 'Music', 'Sports', 'Talk', 'Jazz', 'Classical', 'Pop', 'Rock'];

  static const fallbackStations = [
    StationModel(
      id: 'somafm-groovesalad',
      name: 'Groove Salad (SomaFM)',
      streamUrl: 'https://ice1.somafm.com/groovesalad-128-mp3',
      category: 'Music',
      country: 'US',
    ),
    StationModel(
      id: 'somafm-dronezone',
      name: 'Drone Zone (SomaFM)',
      streamUrl: 'https://ice1.somafm.com/dronezone-128-mp3',
      category: 'Music',
      country: 'US',
    ),
    StationModel(
      id: 'somafm-indiepop',
      name: 'Indie Pop Rocks (SomaFM)',
      streamUrl: 'https://ice1.somafm.com/indiepop-128-mp3',
      category: 'Music',
      country: 'US',
    ),
    StationModel(
      id: 'test-stream',
      name: 'OmniToolkit Test Audio',
      streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      category: 'Music',
      country: 'Test',
    ),
  ];

  Future<List<StationModel>> search(String query) async {
    if (query.trim().isEmpty) return [];
    return _fetchWithFallback('/stations/search', {
      'name': query,
      'limit': '30',
      'hidebroken': 'true',
    });
  }

  Future<List<StationModel>> byCategory(String category) async {
    final path = '/stations/bytag/${Uri.encodeComponent(category.toLowerCase())}';
    return _fetchWithFallback(path, {'limit': '30', 'hidebroken': 'true'});
  }

  Future<List<StationModel>> topStations() async {
    return _fetchWithFallback('/stations/topclick/30', {});
  }

  Future<List<StationModel>> _fetchWithFallback(String path, Map<String, String> queryParams) async {
    for (final host in _hosts) {
      final uri = Uri.https(host, '/json$path', queryParams.isEmpty ? null : queryParams);
      try {
        final response = await http.get(uri, headers: {
          'User-Agent': 'OmniToolkit/1.0 (+https://github.com/omnitoolkit)',
          'Accept': 'application/json',
        }).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final list = jsonDecode(response.body) as List<dynamic>;
          final stations = list
              .map((e) => StationModel.fromJson(e as Map<String, dynamic>))
              .where(_isSafePublicStation)
              .toList();
          if (stations.isNotEmpty) return stations;
        }
      } catch (_) {
        // Try next mirror
      }
    }
    return _offlineFallback();
  }

  /// Offline streams imported from assets/data/radio_streams.json, with the
  /// fallback stations as a last resort if the DB is also empty.
  Future<List<StationModel>> _offlineFallback() async {
    try {
      final offline = await _radioDbService.loadStreams();
      if (offline.isNotEmpty) return offline;
    } catch (_) {}
    return fallbackStations;
  }

  bool _isSafePublicStation(StationModel station) {
    if (station.streamUrl.isEmpty) return false;
    // Allow both HTTP and HTTPS streams
    if (!station.streamUrl.startsWith('http://') && !station.streamUrl.startsWith('https://')) {
      return false;
    }
    final text = '${station.name} ${station.category}'.toLowerCase();
    const blockedTerms = ['premium', 'paid', 'commercial license', 'subscription', 'paywall'];
    return !blockedTerms.any(text.contains);
  }
}
