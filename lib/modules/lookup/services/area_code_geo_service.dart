/// FILE: lib/modules/lookup/services/area_code_geo_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/lookup_models.dart';

/// Loads the unified, offline area-code -> city/state/country/lat-lng
/// dataset (assets/data/area_codes.json, regenerated via
/// tool/generate_area_codes.dart from us-area-code-cities.csv). Each area
/// code maps to one or more cities, so lookups return lists.
class AreaCodeGeoService {
  List<AreaCodeRecord>? _records;

  Future<List<AreaCodeRecord>> _ensureLoaded() async {
    final cached = _records;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString('assets/data/area_codes.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    final records = decoded
        .whereType<Map<String, dynamic>>()
        .map(AreaCodeRecord.fromJson)
        .where((r) => r.areaCode.isNotEmpty && r.city.isNotEmpty)
        .toList();
    _records = records;
    return records;
  }

  /// Full city/state/lat-lng details for every city matching an area-code
  /// prefix (e.g. "20" matches 201, 202, 203, ...).
  Future<List<AreaCodeRecord>> resultsForAreaCode(String query) async {
    final cleaned = query.trim();
    if (cleaned.isEmpty) return const [];
    final records = await _ensureLoaded();
    return records.where((r) => r.areaCode.startsWith(cleaned)).toList();
  }

  /// Autocomplete suggestions ("areaCode (city, state)") for a partial code.
  Future<List<String>> suggestionsForAreaCode(String query, {int limit = 10}) async {
    final results = await resultsForAreaCode(query);
    return results.take(limit).map((r) => '${r.areaCode} (${r.city}, ${r.state})').toList();
  }
}
