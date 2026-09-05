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

  static const genres = [
    'News',
    'Talk Radio',
    'Sports',
    'Pop',
    'Rock',
    'Jazz',
    'Classical',
    'Country',
    'Electronic',
    'Dance',
    'Religious',
    'Oldies',
    'Easy Listening',
    'Community',
    'International',
  ];

  static const categories = genres; // Backward compatibility

  static const countries = [
    CountryInfo(name: 'United States', code: 'US', flag: '🇺🇸'),
    CountryInfo(name: 'Canada', code: 'CA', flag: '🇨🇦'),
    CountryInfo(name: 'United Kingdom', code: 'GB', flag: '🇬🇧'),
    CountryInfo(name: 'Australia', code: 'AU', flag: '🇦🇺'),
    CountryInfo(name: 'India', code: 'IN', flag: '🇮🇳'),
    CountryInfo(name: 'Germany', code: 'DE', flag: '🇩🇪'),
    CountryInfo(name: 'France', code: 'FR', flag: '🇫🇷'),
    CountryInfo(name: 'Japan', code: 'JP', flag: '🇯🇵'),
    CountryInfo(name: 'Italy', code: 'IT', flag: '🇮🇹'),
    CountryInfo(name: 'Spain', code: 'ES', flag: '🇪🇸'),
    CountryInfo(name: 'Brazil', code: 'BR', flag: '🇧🇷'),
    CountryInfo(name: 'Mexico', code: 'MX', flag: '🇲🇽'),
  ];

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

  Future<List<StationModel>> search(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return topStations();
    return _fetchWithFallback('/stations/search', {
      'name': cleanQuery,
      'limit': '50',
      'hidebroken': 'true',
    });
  }

  Future<List<StationModel>> byCategory(String category) async {
    final cleanCat = category.trim().toLowerCase().replaceAll(' ', '');
    final path = '/stations/bytag/$cleanCat';
    return _fetchWithFallback(path, {'limit': '50', 'hidebroken': 'true'});
  }

  Future<List<StationModel>> byCountry(String countryCode) async {
    final path = '/stations/bycodeexact/${countryCode.trim().toLowerCase()}';
    return _fetchWithFallback(path, {'limit': '50', 'hidebroken': 'true'});
  }

  Future<List<StationModel>> topStations() async {
    return _fetchWithFallback('/stations/topclick/50', {});
  }

  Future<List<StationModel>> _fetchWithFallback(String path, Map<String, String> queryParams) async {
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
    return _offlineFallback();
  }

  Future<List<StationModel>> _offlineFallback() async {
    try {
      final offline = await _radioDbService.loadStreams();
      if (offline.isNotEmpty) return offline;
    } catch (_) {}
    return fallbackStations;
  }

  bool _isSafePublicStation(StationModel station) {
    if (station.streamUrl.isEmpty) return false;
    // On Web (HTTPS), filter out insecure HTTP streams up front to prevent browser mixed-content blocks
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
