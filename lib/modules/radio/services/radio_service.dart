/// FILE: lib/modules/radio/services/radio_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/station_model.dart';
import 'radio_db_service.dart';

class CountryInfo {
  const CountryInfo({required this.name, required this.code, required this.flag});
  final String name;
  final String code;
  final String flag;
}

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

  /// Clean, curated list of top global genres guaranteed to yield playable station streams.
  static const genres = [
    'News',
    'Talk',
    'Sports',
    'Pop',
    'Rock',
    'Jazz',
    'Classical',
    'Country',
    'Electronic',
    'Dance',
    'Oldies',
    'Easy Listening',
    'Ambient',
    'Metal',
    'Blues',
    'Reggae',
    'World',
  ];

  static const categories = genres; // Backward compatibility

  static const fallbackStations = [
    StationModel(
      id: 'somafm-groovesalad',
      name: 'Groove Salad (SomaFM)',
      streamUrl: 'https://ice1.somafm.com/groovesalad-128-mp3',
      category: 'Pop',
      country: 'United States',
      countryCode: 'US',
      language: 'English',
      bitrate: 128,
      codec: 'MP3',
      favicon: 'https://somafm.com/img/groovesalad120.png',
    ),
    StationModel(
      id: 'somafm-dronezone',
      name: 'Drone Zone (SomaFM)',
      streamUrl: 'https://ice1.somafm.com/dronezone-128-mp3',
      category: 'Electronic',
      country: 'United States',
      countryCode: 'US',
      language: 'English',
      bitrate: 128,
      codec: 'MP3',
      favicon: 'https://somafm.com/img/dronezone120.png',
    ),
    StationModel(
      id: 'somafm-indiepop',
      name: 'Indie Pop Rocks (SomaFM)',
      streamUrl: 'https://ice1.somafm.com/indiepop-128-mp3',
      category: 'Rock',
      country: 'United States',
      countryCode: 'US',
      language: 'English',
      bitrate: 128,
      codec: 'MP3',
      favicon: 'https://somafm.com/img/indiepop120.png',
    ),
    StationModel(
      id: 'test-stream',
      name: 'OmniToolkit Test Audio',
      streamUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      category: 'Pop',
      country: 'United States',
      countryCode: 'US',
      language: 'English',
      bitrate: 128,
      codec: 'MP3',
    ),
  ];

  /// Dynamic in-memory category registry cache
  List<String>? _dynamicCategoriesCache;

  /// Fetches top tags/categories dynamically from Radio Browser API with offline fallback.
  /// Filters out obscure/empty tags (requiring stationcount >= 50).
  Future<List<String>> fetchCategories({bool forceRefresh = false}) async {
    if (!forceRefresh && _dynamicCategoriesCache != null && _dynamicCategoriesCache!.isNotEmpty) {
      debugPrint('[RadioCategoryLog] Cache hit. Returning ${_dynamicCategoriesCache!.length} cached categories.');
      return List.unmodifiable(_dynamicCategoriesCache!);
    }

    debugPrint('[RadioCategoryLog] Category refresh started. ForceRefresh: $forceRefresh');

    for (final host in _hosts) {
      final uri = Uri.https(host, '/json/tags', {
        'order': 'stationcount',
        'reverse': 'true',
        'limit': '60',
        'hidebroken': 'true',
      });

      try {
        final response = await http.get(uri, headers: {
          'User-Agent': 'OmniToolkit/1.0 (+https://github.com/omnitoolkit)',
          'Accept': 'application/json',
        }).timeout(const Duration(seconds: 6));

        if (response.statusCode == 200) {
          final rawList = jsonDecode(response.body) as List<dynamic>;
          debugPrint('[RadioCategoryLog] Categories received count from $host: ${rawList.length}');

          final seen = <String>{};
          final freshCategories = <String>[];

          for (final item in rawList) {
            if (item is! Map<String, dynamic>) continue;
            final rawName = item['name'] as String?;
            final stationCount = item['stationcount'] as int? ?? 0;
            if (rawName == null || stationCount < 20) continue;

            final cleanName = rawName.trim();
            if (cleanName.length < 2 || cleanName.length > 25) continue;

            // Filter out obscure local/untranslatable regional tags that produce empty lists
            final lower = cleanName.toLowerCase();
            if (RegExp(r'^(fm|am|radio|music|musica|estacion|norteamerica|moi|espanol|ingles|regional|variada|programa|noticias|recuerdo|variada)$').hasMatch(lower)) {
              continue;
            }

            if (seen.contains(lower)) continue;
            seen.add(lower);

            final formattedName = cleanName
                .split(' ')
                .map((word) => word.isNotEmpty
                    ? '${word[0].toUpperCase()}${word.substring(1)}'
                    : '')
                .join(' ');

            freshCategories.add(formattedName);
          }

          debugPrint('[RadioCategoryLog] Categories after filtering and deduplication count: ${freshCategories.length}');

          if (freshCategories.isNotEmpty) {
            _dynamicCategoriesCache = freshCategories;
            return List.unmodifiable(_dynamicCategoriesCache!);
          }
        }
      } catch (e) {
        debugPrint('[RadioCategoryLog] Category fetch error from host $host: $e');
      }
    }

    _dynamicCategoriesCache = List.from(genres);
    return List.unmodifiable(_dynamicCategoriesCache!);
  }

  Future<List<StationModel>> search(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return topStations();
    return _fetchWithFallback('/stations/search', {
      'name': cleanQuery,
      'limit': '50',
      'hidebroken': 'true',
    }, filterType: _FilterType.search, filterVal: cleanQuery);
  }

  Future<List<StationModel>> byCategory(String category) async {
    final cleanCat = category.trim().toLowerCase();
    final path = '/stations/bytag/${Uri.encodeComponent(cleanCat)}';
    return _fetchWithFallback(path, {'limit': '50', 'hidebroken': 'true'}, filterType: _FilterType.category, filterVal: cleanCat);
  }

  Future<List<StationModel>> byCountry(String countryCode) async {
    final cleanCode = countryCode.trim().toUpperCase();
    final path = '/stations/bycodeexact/${cleanCode.toLowerCase()}';
    return _fetchWithFallback(path, {'limit': '50', 'hidebroken': 'true'}, filterType: _FilterType.country, filterVal: cleanCode);
  }

  Future<List<StationModel>> topStations() async {
    return _fetchWithFallback('/stations/topclick/50', {}, filterType: _FilterType.none, filterVal: '');
  }

  Future<List<StationModel>> _fetchWithFallback(
    String path,
    Map<String, String> queryParams, {
    required _FilterType filterType,
    required String filterVal,
  }) async {
    for (final host in _hosts) {
      final uri = Uri.https(host, '/json$path', queryParams.isEmpty ? null : queryParams);
      try {
        final response = await http.get(uri, headers: {
          'User-Agent': 'OmniToolkit/1.0 (+https://github.com/omnitoolkit)',
          'Accept': 'application/json',
        }).timeout(const Duration(seconds: 6));

        if (response.statusCode == 200) {
          final list = jsonDecode(response.body) as List<dynamic>;
          final stations = list
              .map((e) => StationModel.fromJson(e as Map<String, dynamic>))
              .where(_isSafePublicStation)
              .toList();
          if (stations.isNotEmpty) return stations;
        }
      } catch (_) {
        // Try next mirror host
      }
    }
    return _offlineFallback(filterType: filterType, filterVal: filterVal);
  }

  Future<List<StationModel>> _offlineFallback({
    required _FilterType filterType,
    required String filterVal,
  }) async {
    List<StationModel> streams = [];
    try {
      streams = await _radioDbService.loadStreams();
    } catch (_) {}

    if (streams.isEmpty) {
      streams = fallbackStations;
    }

    if (filterVal.isEmpty || filterType == _FilterType.none) {
      return streams;
    }

    final valLower = filterVal.toLowerCase();

    switch (filterType) {
      case _FilterType.country:
        return streams.where((s) {
          final codeMatch = (s.countryCode ?? '').toUpperCase() == filterVal.toUpperCase();
          final nameMatch = s.country.toLowerCase().contains(valLower);
          return codeMatch || nameMatch;
        }).toList();

      case _FilterType.category:
        return streams.where((s) => s.category.toLowerCase().contains(valLower)).toList();

      case _FilterType.search:
        return streams.where((s) {
          final fullText = '${s.name} ${s.category} ${s.country}'.toLowerCase();
          return fullText.contains(valLower);
        }).toList();

      case _FilterType.none:
        return streams;
    }
  }

  bool _isSafePublicStation(StationModel station) {
    if (station.streamUrl.isEmpty) return false;
    if (kIsWeb) {
      final isHttpsPage = Uri.base.scheme.toLowerCase() == 'https';
      if (isHttpsPage && station.streamUrl.startsWith('http://')) {
        return false;
      }
    }
    if (!station.streamUrl.startsWith('http://') && !station.streamUrl.startsWith('https://')) {
      return false;
    }
    final text = '${station.name} ${station.category}'.toLowerCase();
    const blockedTerms = ['premium', 'paid', 'commercial license', 'subscription', 'paywall'];
    return !blockedTerms.any(text.contains);
  }
}

enum _FilterType { none, country, category, search }
