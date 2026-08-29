/// FILE: lib/modules/radio/services/favorites_service.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/station_model.dart';

/// Persists favorite radio stations using SharedPreferences.
class FavoritesService {
  static const _key = 'radio_favorites';

  Future<List<StationModel>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((s) => StationModel.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFavorites(List<StationModel> stations) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = stations.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_key, raw);
  }
}
