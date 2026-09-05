/// FILE: lib/modules/lookup/services/area_code_geo_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/lookup_models.dart';

/// Loads the unified, offline area-code -> city/state/country/lat-lng
/// dataset (assets/data/area_codes.json).
class AreaCodeGeoService {
  List<AreaCodeRecord>? _records;

  Future<List<AreaCodeRecord>> _ensureLoaded() async {
    final cached = _records;
    if (cached != null) return cached;

    String? raw;
    try {
      raw = await rootBundle.loadString('assets/data/area_codes.json');
    } catch (_) {
      try {
        raw = await rootBundle.loadString('area_codes.json');
      } catch (_) {}
    }

    if (raw == null || raw.isEmpty) {
      _records = [];
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    final records = decoded
        .whereType<Map<String, dynamic>>()
        .map(AreaCodeRecord.fromJson)
        .where((r) => r.areaCode.isNotEmpty && r.city.isNotEmpty)
        .toList();
    _records = records;
    return records;
  }

  /// Full city/state/lat-lng details for every city matching an area-code,
  /// ZIP code, or city name.
  Future<List<AreaCodeRecord>> resultsForAreaCode(String query) async {
    final cleaned = query.trim();
    if (cleaned.isEmpty) return const [];
    final records = await _ensureLoaded();
    final lower = cleaned.toLowerCase();

    // 1. Matches area code directly (starts with or equals)
    final byAreaCode = records.where((r) => r.areaCode.startsWith(cleaned) || r.areaCode == cleaned).toList();
    if (byAreaCode.isNotEmpty) return byAreaCode;

    // 2. Matches city name or state code (e.g. "Dallas", "New York", "PA")
    final cityPart = lower.split(',').first.trim();
    final byCity = records.where((r) => r.city.toLowerCase().contains(cityPart) || r.state.toLowerCase() == cityPart).toList();
    if (byCity.isNotEmpty) return byCity;

    return const [];
  }

  /// Autocomplete suggestions ("areaCode (city, state)") for a partial code, city, or ZIP.
  Future<List<String>> suggestionsForAreaCode(String query, {int limit = 10}) async {
    final results = await resultsForAreaCode(query);
    return results.take(limit).map((r) => '${r.areaCode} (${r.city}, ${r.state})').toList();
  }
}
