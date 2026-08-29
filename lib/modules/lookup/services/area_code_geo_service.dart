/// FILE: lib/modules/lookup/services/area_code_geo_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/lookup_models.dart';

/// Loads the unified, offline area-code -> city/state/county/timezone/lat-lng
/// dataset (assets/data/area_codes.json, regenerated via
/// tool/generate_area_codes.dart) and serves single-record lookups by NPA.
class AreaCodeGeoService {
  Map<String, AreaCodeRecord>? _byAreaCode;

  Future<Map<String, AreaCodeRecord>> _ensureLoaded() async {
    final cached = _byAreaCode;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString('assets/data/area_codes.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    final map = <String, AreaCodeRecord>{};
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) continue;
      final record = AreaCodeRecord.fromJson(item);
      if (record.areaCode.isEmpty || record.city.isEmpty) continue;
      map[record.areaCode] = record;
    }
    _byAreaCode = map;
    return map;
  }

  /// Returns the aggregated record for an exact 3-digit area code, if known.
  Future<AreaCodeRecord?> lookup(String areaCode) async {
    final cleaned = areaCode.trim();
    if (cleaned.isEmpty) return null;
    final byAreaCode = await _ensureLoaded();
    return byAreaCode[cleaned];
  }
}
