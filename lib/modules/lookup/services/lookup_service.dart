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

  // Security: Limits to prevent DoS via malformed data
  static const int _maxCsvRows = 50000;
  static const int _maxCsvLineLength = 500;
  static const int _maxJsonRecords = 10000;

  Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    try {
      await loadFromLocalAssets().timeout(const Duration(seconds: 5));
    } catch (e) {
      _debugLog('[LookupService] Asset load timeout or error: $e');
      _loadFallbackSeedData();
    }
    _isInitialized = true;
  }

  Future<void> loadFromLocalAssets() async {
    // 1. Try loading curated_us_zips.csv
    try {
      String? csvContent;
      try {
        csvContent = await rootBundle.loadString('assets/data/curated_us_zips.csv');
      } catch (e1) {
        _debugLog('[LookupService] Primary asset path load error: $e1');
        try {
          csvContent = await rootBundle.loadString('curated_us_zips.csv');
        } catch (e2) {
          _debugLog('[LookupService] Secondary asset path load error: $e2');
        }
      }

      if (csvContent != null && csvContent.isNotEmpty) {
        parseZipCsv(csvContent);
        _debugLog('[LookupService] Successfully loaded ${zipData.length} ZIP records from CSV');
      }
    } catch (e) {
      _debugLog('[LookupService] Error loading curated_us_zips.csv: $e');
    }

    // 2. Try loading lookup_data.json
    try {
      String? rawJson;
      try {
        rawJson = await rootBundle.loadString('assets/data/lookup_data.json');
      } catch (_) {
        try {
          rawJson = await rootBundle.loadString('lookup_data.json');
        } catch (_) {}
      }

      if (rawJson != null && rawJson.isNotEmpty) {
        final decoded = jsonDecode(rawJson);
        parseAreaCodesJson(decoded);
      }
    } catch (e) {
      _debugLog('[LookupService] Error loading lookup_data.json: $e');
    }

    if (zipData.isEmpty) {
      _loadFallbackSeedData();
    }
  }

  void parseZipCsv(String csvContent) {
    final lines = csvContent.split('\n');
    if (lines.isEmpty) return;

    // Security: Limit total rows to prevent memory exhaustion
    int processedRows = 0;
    final startIdx = lines.first.startsWith('zip,') ? 1 : 0;
    for (var i = startIdx; i < lines.length && processedRows < _maxCsvRows; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // Security: Limit line length to prevent ReDoS
      if (line.length > _maxCsvLineLength) {
        _debugLog('[LookupService] Skipping oversized CSV line (${line.length} chars)');
        continue;
      }

      final parts = _parseCsvLine(line);
      if (parts.length >= 3) {
        final rawZip = parts[0].replaceAll('"', '').trim();
        if (rawZip.isEmpty) continue;
        // Validate ZIP format (5 digits)
        if (!RegExp(r'^\d{5}$').hasMatch(rawZip)) {
          continue;
        }
        final cleanZip = rawZip.padLeft(5, '0');
        final city = _sanitizeField(parts[1].replaceAll('"', '').trim());
        final state = _sanitizeField(parts[2].replaceAll('"', '').trim());

        // Validate state code (2 letters)
        if (!RegExp(r'^[A-Z]{2}$').hasMatch(state)) {
          continue;
        }

        final county = parts.length > 3 ? _sanitizeField(parts[3].replaceAll('"', '').trim()) : null;
        final timezone = parts.length > 4 ? _sanitizeField(parts[4].replaceAll('"', '').trim()) : null;
        final lat = parts.length > 5 ? double.tryParse(parts[5].replaceAll('"', '')) : null;
        final lng = parts.length > 6 ? double.tryParse(parts[6].replaceAll('"', '')) : null;

        // Validate coordinates
        if (lat != null && (lat < -90 || lat > 90)) continue;
        if (lng != null && (lng < -180 || lng > 180)) continue;

        addZipRecord(ZipRecord(
          zip: cleanZip,
          city: city,
          state: state,
          county: county?.isEmpty == true ? null : county,
          timezone: timezone?.isEmpty == true ? null : timezone,
          lat: lat,
          lng: lng,
        ));
        processedRows++;
      }
    }

    if (processedRows >= _maxCsvRows) {
      _debugLog('[LookupService] CSV row limit reached ($_maxCsvRows), remaining lines ignored');
    }
  }

  void parseAreaCodesJson(dynamic decoded) {
    List<dynamic> records = [];
    if (decoded is Map && decoded.containsKey('records')) {
      records = decoded['records'] as List<dynamic>;
    } else if (decoded is List) {
      records = decoded;
    }

    // Security: Limit total records
    int processedRecords = 0;
    for (final item in records) {
      if (processedRecords >= _maxJsonRecords) break;
      if (item is! Map) continue;
      final fields = (item.containsKey('fields') && item['fields'] is Map)
          ? item['fields'] as Map<String, dynamic>
          : item as Map<String, dynamic>;

      final rawCode = (fields['area_code'] ?? fields['areaCode'] ?? fields['code'])?.toString() ?? '';
      final city = (fields['city'] ?? fields['name'])?.toString() ?? '';
      final state = (fields['state'] ?? fields['state_code'])?.toString() ?? '';

      if (rawCode.isNotEmpty && city.isNotEmpty && state.isNotEmpty) {
        // Validate area code format (3 digits)
        final cleanCode = rawCode.trim();
        if (!RegExp(r'^\d{3}$').hasMatch(cleanCode)) continue;

        // Validate state
        final cleanState = _sanitizeField(state.trim());
        if (!RegExp(r'^[A-Z]{2}$').hasMatch(cleanState)) continue;

        final cleanCity = _sanitizeField(city.trim());
        final rec = AreaCodeRecord(
          areaCode: cleanCode,
          city: cleanCity,
          state: cleanState,
          country: fields['country']?.toString(),
          lat: double.tryParse(fields['lat']?.toString() ?? ''),
          lng: double.tryParse(fields['lng']?.toString() ?? ''),
        );

        // Validate coordinates if present
        if (rec.lat != null && (rec.lat! < -90 || rec.lat! > 90)) continue;
        if (rec.lng != null && (rec.lng! < -180 || rec.lng! > 180)) continue;

        addAreaCodeRecord(rec);
        processedRecords++;
      }
    }

    if (processedRecords >= _maxJsonRecords) {
      _debugLog('[LookupService] JSON record limit reached ($_maxJsonRecords), remaining records ignored');
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
          if (trimmed.isNotEmpty && RegExp(r'^\d{3}$').hasMatch(trimmed)) {
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
    final cleanZip = _sanitizeZip(zip);
    if (cleanZip == null) return [];
    final rec = zipData[cleanZip] ?? zipData[zip.trim()];
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
    final cleanCode = _sanitizeAreaCode(areaCode);
    if (cleanCode == null) return [];
    final list = areaCodeData[cleanCode] ?? [];
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
    final cleanZip = _sanitizeZip(zip);
    if (cleanZip == null) return null;
    final rec = zipData[cleanZip] ?? zipData[zip.trim()];
    return rec != null ? '${rec.city}, ${rec.state}' : null;
  }

  List<String> lookupZipsFromCity(String cityAndState) {
    final parts = cityAndState.split(',');
    final cityPart = _sanitizeField(parts[0].trim().toLowerCase());
    final statePart = parts.length > 1 ? _sanitizeField(parts[1].trim().toLowerCase()) : '';

    if (cityPart.isEmpty) return [];

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
    final cleanCode = _sanitizeAreaCode(areaCode);
    if (cleanCode == null) return null;
    final list = areaCodeData[cleanCode];
    if (list == null || list.isEmpty) return null;
    final first = list.first;
    return '${first.city}, ${first.state}';
  }

  List<String> lookupAreaCodesFromCity(String cityAndState) {
    final parts = cityAndState.split(',');
    final cityPart = _sanitizeField(parts[0].trim().toLowerCase());
    final statePart = parts.length > 1 ? _sanitizeField(parts[1].trim().toLowerCase()) : '';

    if (cityPart.isEmpty) return [];

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

  /// Sanitize ZIP code input - must be 5 digits
  String? _sanitizeZip(String zip) {
    final trimmed = zip.trim();
    final clean = trimmed.padLeft(5, '0');
    if (RegExp(r'^\d{5}$').hasMatch(clean)) {
      return clean;
    }
    return null;
  }

  /// Sanitize area code input - must be 3 digits
  String? _sanitizeAreaCode(String areaCode) {
    final trimmed = areaCode.trim();
    if (RegExp(r'^\d{3}$').hasMatch(trimmed)) {
      return trimmed;
    }
    return null;
  }

  /// Sanitize text fields - remove control chars, limit length
  String _sanitizeField(String input) {
    return input
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '')
        .substring(0, input.length.clamp(0, 100));
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

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}