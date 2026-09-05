/// FILE: lib/modules/lookup/services/lookup_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/lookup_models.dart';
import '../data/zip_seed_data.dart';

/// ZIP ↔ Area Code ↔ City Cross-Lookup Service.
class LookupService {
  /// In-Memory Maps
  final Map<String, ZipRecord> zipData = {};
  final Map<String, List<AreaCodeRecord>> areaCodeData = {};

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    try {
      await loadFromLocalAssets().timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('[LookupService] Asset load timeout or error: $e');
      _loadFallbackSeedData();
    }
    _isInitialized = true;
  }

  Future<void> loadFromLocalAssets() async {
    try {
      final csvContent = await rootBundle.loadString('assets/data/curated_us_zips.csv');
      parseZipCsv(csvContent);
    } catch (e) {
      debugPrint('[LookupService] Error loading curated_us_zips.csv: $e');
    }

    try {
      final rawJson = await rootBundle.loadString('assets/data/lookup_data.json');
      final decoded = jsonDecode(rawJson);
      parseAreaCodesJson(decoded);
    } catch (e) {
      debugPrint('[LookupService] Error loading lookup_data.json: $e');
    }

    if (zipData.isEmpty) {
      _loadFallbackSeedData();
    }
  }

  void parseZipCsv(String csvContent) {
    final lines = csvContent.split('\n');
    if (lines.isEmpty) return;

    final startIdx = lines.first.startsWith('zip,') ? 1 : 0;
    for (var i = startIdx; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final parts = _parseCsvLine(line);
      if (parts.length >= 3) {
        final zip = parts[0].replaceAll('"', '').trim();
        final city = parts[1].replaceAll('"', '').trim();
        final state = parts[2].replaceAll('"', '').trim();
        final county = parts.length > 3 ? parts[3].replaceAll('"', '').trim() : null;
        final timezone = parts.length > 4 ? parts[4].replaceAll('"', '').trim() : null;
        final lat = parts.length > 5 ? double.tryParse(parts[5].replaceAll('"', '')) : null;
        final lng = parts.length > 6 ? double.tryParse(parts[6].replaceAll('"', '')) : null;

        addZipRecord(ZipRecord(
          zip: zip,
          city: city,
          state: state,
          county: county?.isEmpty == true ? null : county,
          timezone: timezone?.isEmpty == true ? null : timezone,
          lat: lat,
          lng: lng,
        ));
      }
    }
  }

  void parseAreaCodesJson(dynamic decoded) {
    List<dynamic> records = [];
    if (decoded is Map && decoded.containsKey('records')) {
      records = decoded['records'] as List<dynamic>;
    } else if (decoded is List) {
      records = decoded;
    }

    for (final item in records) {
      if (item is! Map) continue;
      final fields = (item.containsKey('fields') && item['fields'] is Map)
          ? item['fields'] as Map<String, dynamic>
          : item as Map<String, dynamic>;

      final rawCode = (fields['area_code'] ?? fields['areaCode'] ?? fields['code'])?.toString() ?? '';
      final city = (fields['city'] ?? fields['name'])?.toString() ?? '';
      final state = (fields['state'] ?? fields['state_code'])?.toString() ?? '';

      if (rawCode.isNotEmpty && city.isNotEmpty && state.isNotEmpty) {
        final rec = AreaCodeRecord(
          areaCode: rawCode.trim(),
          city: city.trim(),
          state: state.trim(),
          country: fields['country']?.toString(),
          lat: double.tryParse(fields['lat']?.toString() ?? ''),
          lng: double.tryParse(fields['lng']?.toString() ?? ''),
        );
        addAreaCodeRecord(rec);
      }
    }
  }

  void addZipRecord(ZipRecord record) {
    zipData[record.zip] = record;
  }

  void addAreaCodeRecord(AreaCodeRecord record) {
    areaCodeData.putIfAbsent(record.areaCode, () => []).add(record);
  }

  void _loadFallbackSeedData() {
    for (final entry in zipSeedData) {
      addZipRecord(ZipRecord(
        zip: entry.zip,
        city: entry.city,
        state: entry.state,
        county: entry.county,
        timezone: entry.timezone,
        lat: entry.lat,
        lng: entry.lng,
      ));
      if (entry.areaCode.isNotEmpty) {
        for (final code in entry.areaCode.split(',')) {
          final trimmed = code.trim();
          if (trimmed.isNotEmpty) {
            addAreaCodeRecord(AreaCodeRecord(
              areaCode: trimmed,
              city: entry.city,
              state: entry.state,
              lat: entry.lat,
              lng: entry.lng,
            ));
          }
        }
      }
    }
  }

  List<String> lookupAreaCodesFromZip(String zip) {
    final rec = zipData[zip.trim()];
    if (rec == null) return [];
    final matches = <String>{};
    areaCodeData.forEach((code, list) {
      if (list.any((a) => a.city.toLowerCase() == rec.city.toLowerCase() && a.state.toLowerCase() == rec.state.toLowerCase())) {
        matches.add(code);
      }
    });
    return matches.toList()..sort();
  }

  List<String> lookupZipsFromAreaCode(String areaCode) {
    final list = areaCodeData[areaCode.trim()] ?? [];
    final zips = <String>{};
    for (final ac in list) {
      zipData.forEach((z, rec) {
        if (rec.city.toLowerCase() == ac.city.toLowerCase() && rec.state.toLowerCase() == ac.state.toLowerCase()) {
          zips.add(z);
        }
      });
    }
    return zips.toList()..sort();
  }

  String? lookupCityFromZip(String zip) {
    final rec = zipData[zip.trim()];
    return rec != null ? '${rec.city}, ${rec.state}' : null;
  }

  List<String> lookupZipsFromCity(String cityAndState) {
    final parts = cityAndState.split(',');
    final cityPart = parts[0].trim().toLowerCase();
    final statePart = parts.length > 1 ? parts[1].trim().toLowerCase() : '';

    final zips = <String>[];
    zipData.forEach((z, rec) {
      final matchesCity = rec.city.toLowerCase() == cityPart;
      final matchesState = statePart.isEmpty || rec.state.toLowerCase() == statePart;
      if (matchesCity && matchesState) {
        zips.add(z);
      }
    });
    return zips..sort();
  }

  String? lookupCityFromAreaCode(String areaCode) {
    final list = areaCodeData[areaCode.trim()];
    if (list == null || list.isEmpty) return null;
    final first = list.first;
    return '${first.city}, ${first.state}';
  }

  List<String> lookupAreaCodesFromCity(String cityAndState) {
    final parts = cityAndState.split(',');
    final cityPart = parts[0].trim().toLowerCase();
    final statePart = parts.length > 1 ? parts[1].trim().toLowerCase() : '';

    final codes = <String>{};
    areaCodeData.forEach((code, list) {
      for (final ac in list) {
        final matchesCity = ac.city.toLowerCase() == cityPart;
        final matchesState = statePart.isEmpty || ac.state.toLowerCase() == statePart;
        if (matchesCity && matchesState) {
          codes.add(code);
        }
      }
    });
    return codes.toList()..sort();
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    var inQuotes = false;
    final current = StringBuffer();
    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString().trim());
        current.clear();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString().trim());
    return result;
  }
}
