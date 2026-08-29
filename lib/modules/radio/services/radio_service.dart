/// FILE: lib/modules/radio/services/radio_service.dart
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

  static const _base = 'https://de1.api.radio-browser.info/json';

  static const categories = ['News', 'Music', 'Sports', 'Talk', 'Jazz', 'Classical', 'Pop', 'Rock'];
  static const fallbackStations = [
    StationModel(id: 'test', name: 'OmniToolkit Test Stream',
      streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      category: 'Music', country: 'Test'),
  ];

  Future<List<StationModel>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final uri = Uri.parse('$_base/stations/search').replace(queryParameters: {
      'name': query,
      'limit': '30',
      'hidebroken': 'true',
    });
    return _fetch(uri);
  }

  Future<List<StationModel>> byCategory(String category) async {
    final uri = Uri.parse('$_base/stations/bytag/${Uri.encodeComponent(category.toLowerCase())}')
        .replace(queryParameters: {'limit': '30', 'hidebroken': 'true'});
    return _fetch(uri);
  }

  Future<List<StationModel>> topStations() async {
    final uri = Uri.parse('$_base/stations/topclick/30');
    return _fetch(uri);
  }

  Future<List<StationModel>> _fetch(Uri uri) async {
    late http.Response response;
    try {
      response = await http.get(uri, headers: {
        'User-Agent': 'OmniToolkit/1.0 (+https://github.com/omnitoolkit)',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 12));
    } catch (_) {
      return _offlineFallback();
    }
    if (response.statusCode != 200) return _offlineFallback();
    final list = jsonDecode(response.body) as List<dynamic>;
    final stations = list.map((e) => StationModel.fromJson(e as Map<String, dynamic>))
        .where(_isSafePublicStation).toList();
    return stations.isEmpty ? await _offlineFallback() : stations;
  }

  /// Offline streams imported from assets/data/radio_streams.json, with the
  /// single hardcoded stream as a last resort if the DB is also empty.
  Future<List<StationModel>> _offlineFallback() async {
    try {
      final offline = await _radioDbService.loadStreams();
      if (offline.isNotEmpty) return offline;
    } catch (_) {}
    return fallbackStations;
  }

  bool _isSafePublicStation(StationModel station) {
    if (station.streamUrl.isEmpty) return false;
    if (!station.streamUrl.startsWith('https://')) return false;
    final text = '${station.name} ${station.category}'.toLowerCase();
    const blockedTerms = ['premium', 'paid', 'commercial license', 'subscription', 'paywall'];
    return !blockedTerms.any(text.contains);
  }
}
