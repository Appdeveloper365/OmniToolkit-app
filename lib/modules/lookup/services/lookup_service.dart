/// FILE: lib/modules/lookup/services/lookup_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import '../models/lookup_models.dart';
import '../data/zip_seed_data.dart';

/// ZIP ↔ Area Code ↔ City Cross-Lookup Service.
class LookupService {
  /// Remote data source endpoints
  static const String zipCsvUrl =
      'https://raw.githubusercontent.com/Appdeveloper365/us-zip-area-dataset/main/curated_us_zips.csv';
  static const String areaCodeApiUrl =
      'https://public.opendatasoft.com/api/records/1.0/search/?dataset=nanpa-area-codes&q=&rows=50000';

  /// In-Memory Maps
  /// 1. zipData: key: zip -> value: ZipRecord { zip, city, state, county, timezone, lat, lng }
  final Map<String, ZipRecord> zipData = {};

  /// 2. areaCodeData: key: area_code -> value: List<AreaCodeRecord> { area_code, city, state }
  final Map<String, List<AreaCodeRecord>> areaCodeData = {};

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Ensures data is loaded from local bundled assets / fallback,
  /// and optionally attempts remote sync from GitHub / OpenDataSoft endpoints.
  Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    await loadFromLocalAssets();
    _isInitialized = true;
    // Asynchronously sync from remote sources if internet is available
    fetchAndSyncRemoteData().catchError((_) {});
  }

  /// Loads datasets from local assets / seed data.
  Future<void> loadFromLocalAssets() async {
    // 1. Try loading curated_us_zips.csv from asset or local file
    try {
      final csvContent = await rootBundle.loadString('assets/data/curated_us_zips.csv');
      parseZipCsv(csvContent);
    } catch (_) {
      try {
        final file = File('curated_us_zips.csv');
        if (file.existsSync()) {
          parseZipCsv(file.readAsStringSync());
        }
      } catch (_) {}
    }

    // 2. Load area code data from bundled JSON or seed data
    try {
      final rawJson = await rootBundle.loadString('assets/data/lookup_data.json');
      final decoded = jsonDecode(rawJson);
      parseAreaCodesJson(decoded);
    } catch (_) {
      try {
        final file = File('assets/data/lookup_data.json');
        if (file.existsSync()) {
          final decoded = jsonDecode(file.readAsStringSync());
          parseAreaCodesJson(decoded);
        }
      } catch (_) {}
    }

    // Fallback seed data if maps are empty
    if (zipData.isEmpty) {
      _loadFallbackSeedData();
    }
  }

  /// Fetches and parses remote datasets from the specified endpoints.
  Future<void> fetchAndSyncRemoteData() async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);

    // 1. Fetch ZIP dataset from GitHub
    try {
      final req = await client.getUrl(Uri.parse(zipCsvUrl));
      final res = await req.close();
      if (res.statusCode == 200) {
        final csvContent = await res.transform(utf8.decoder).join();
        parseZipCsv(csvContent);
      }
    } catch (_) {}

    // 2. Fetch Area Code dataset from OpenDataSoft
    // NOTE: as of this writing, dataset id "nanpa-area-codes" no longer
    // exists on OpenDataSoft (the API returns "Unknown dataset"). This call
    // is left in place defensively (catch-and-ignore below) in case the
    // dataset is restored; area-code data is otherwise served entirely from
    // local bundled assets (see loadFromLocalAssets / assets/data/area_codes.json,
    // regenerated offline via tool/generate_area_codes.dart).
    try {
      var req = await client.getUrl(Uri.parse(areaCodeApiUrl));
      var res = await req.close();
      if (res.statusCode != 200) {
        // Retry with rows=10000 if rows=50000 was rejected by OpenDataSoft API limit
        const retryUrl =
            'https://public.opendatasoft.com/api/records/1.0/search/?dataset=nanpa-area-codes&q=&rows=10000';
        req = await client.getUrl(Uri.parse(retryUrl));
        res = await req.close();
      }
      if (res.statusCode == 200) {
        final body = await res.transform(utf8.decoder).join();
        final decoded = jsonDecode(body);
        parseAreaCodesJson(decoded);
      }
    } catch (_) {}

    client.close();
  }

  /// Parses CSV format for ZIP dataset (zip, city, state, county, timezone, lat, lng).
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

  /// Parses JSON records for Area Code dataset (area_code, city, state,
  /// and county/timezone/lat-lng when the source row provides them).
  void parseAreaCodesJson(dynamic decoded) {
    List<dynamic> records = [];
    if (decoded is Map && decoded.containsKey('records')) {
      records = decoded['records'] as List<dynamic>;
    } else if (decoded is List) {
      records = decoded;
    }

    for (final item in records) {
      if (item is! Map) continue;
      final fields = item.containsKey('fields') ? item['fields'] : item;
      if (fields is! Map) continue;

      final acVal = fields['area_code'] ?? fields['areaCode'];
      final cityVal = fields['city'] ?? fields['usps_city'];
      final stateVal = fields['state'] ?? fields['stusps_code'];
      final countyVal = fields['county'] as String?;
      final timezoneVal = fields['timezone'] as String?;
      final lat = (fields['lat'] as num?)?.toDouble();
      final lng = (fields['lng'] as num?)?.toDouble();

      if (acVal != null && cityVal != null) {
        final cityStr = cityVal.toString().trim();
        final stateStr = (stateVal ?? '').toString().trim();

        final codes = acVal is List ? acVal : [acVal.toString()];
        for (final c in codes) {
          addAreaCodeRecord(AreaCodeRecord(
            areaCode: c.toString().trim(),
            city: cityStr,
            state: stateStr,
            county: countyVal?.trim(),
            timezone: timezoneVal?.trim(),
            lat: lat,
            lng: lng,
          ));
        }
      }
    }
  }

  /// Adds a ZipRecord to [zipData] with validation and deduplication.
  void addZipRecord(ZipRecord record) {
    final cleanZ = cleanZip(record.zip);
    if (cleanZ == null) return;

    zipData[cleanZ] = ZipRecord(
      zip: cleanZ,
      city: record.city.trim(),
      state: record.state.trim(),
      county: record.county?.trim(),
      timezone: record.timezone?.trim(),
      lat: record.lat,
      lng: record.lng,
    );
  }

  /// Adds an AreaCodeRecord to [areaCodeData] with validation and deduplication.
  void addAreaCodeRecord(AreaCodeRecord record) {
    final cleanCode = cleanAreaCode(record.areaCode);
    if (cleanCode == null) return;

    final city = record.city.trim();
    final state = record.state.trim();
    if (city.isEmpty) return;

    final list = areaCodeData.putIfAbsent(cleanCode, () => []);
    final exists = list.any((r) =>
        r.city.toLowerCase() == city.toLowerCase() &&
        r.state.toLowerCase() == state.toLowerCase());

    if (!exists) {
      list.add(AreaCodeRecord(
        areaCode: cleanCode,
        city: city,
        state: state,
        county: record.county?.trim(),
        timezone: record.timezone?.trim(),
        lat: record.lat,
        lng: record.lng,
      ));
    }
  }

  // =========================================================================
  // VALIDATION HELPERS
  // =========================================================================

  /// Validates if a string is a 5-digit ZIP code.
  static bool isValidZip(String zip) {
    return RegExp(r'^\d{5}$').hasMatch(zip.trim());
  }

  /// Cleans and formats a ZIP code to 5 digits, returning null if invalid.
  static String? cleanZip(String zip) {
    var s = zip.trim();
    if (s.length < 5 && RegExp(r'^\d+$').hasMatch(s)) {
      s = s.padLeft(5, '0');
    }
    return RegExp(r'^\d{5}$').hasMatch(s) ? s : null;
  }

  /// Validates if a string is a 3-digit area code.
  static bool isValidAreaCode(String code) {
    return RegExp(r'^\d{3}$').hasMatch(code.trim());
  }

  /// Cleans and formats an area code to 3 digits, returning null if invalid.
  static String? cleanAreaCode(String code) {
    final s = code.trim();
    return RegExp(r'^\d{3}$').hasMatch(s) ? s : null;
  }

  // =========================================================================
  // CROSS-LOOKUP MODULE FUNCTIONS
  // =========================================================================

  /// 1. ZIP → Area Code
  /// - Use ZIP → city/state
  /// - Match city/state in areaCodeData
  /// - Return all matching area codes (deduplicated & sorted ascending)
  List<String> lookupAreaCodesFromZip(String zip) {
    final cleanZ = cleanZip(zip);
    if (cleanZ == null) return const [];

    final zipRecord = zipData[cleanZ];
    if (zipRecord == null) return const [];

    final targetCity = zipRecord.city.toLowerCase().trim();
    final targetState = zipRecord.state.toLowerCase().trim();

    final matchedCodes = <String>{};

    areaCodeData.forEach((code, records) {
      if (isValidAreaCode(code)) {
        for (final r in records) {
          if (r.city.toLowerCase().trim() == targetCity &&
              (targetState.isEmpty || r.state.toLowerCase().trim() == targetState)) {
            matchedCodes.add(code);
            break;
          }
        }
      }
    });

    final result = matchedCodes.toList()..sort();
    return result;
  }

  /// 2. Area Code → ZIP
  /// - Use area_code → city/state
  /// - Match city/state in zipData
  /// - Return all matching ZIP codes (deduplicated & sorted ascending)
  List<String> lookupZipsFromAreaCode(String areaCode) {
    final cleanCode = cleanAreaCode(areaCode);
    if (cleanCode == null) return const [];

    final records = areaCodeData[cleanCode];
    if (records == null || records.isEmpty) return const [];

    final cityStates = records
        .map((r) => '${r.city.toLowerCase().trim()}|${r.state.toLowerCase().trim()}')
        .toSet();

    final matchedZips = <String>{};

    zipData.forEach((z, record) {
      if (isValidZip(z)) {
        final key1 = '${record.city.toLowerCase().trim()}|${record.state.toLowerCase().trim()}';
        final key2 = '${record.city.toLowerCase().trim()}|';
        if (cityStates.contains(key1) || cityStates.any((cs) => cs.startsWith(key2))) {
          matchedZips.add(z);
        }
      }
    });

    final result = matchedZips.toList()..sort();
    return result;
  }

  /// 3. ZIP → City
  /// Returns the city name for a given ZIP code or null if not found.
  String? lookupCityFromZip(String zip) {
    final cleanZ = cleanZip(zip);
    if (cleanZ == null) return null;
    return zipData[cleanZ]?.city;
  }

  /// 4. City → ZIP
  /// Returns all matching ZIP codes for a given city (deduplicated & sorted ascending).
  List<String> lookupZipsFromCity(String city) {
    final target = city.toLowerCase().trim();
    if (target.isEmpty) return const [];

    final matchedZips = <String>{};

    zipData.forEach((z, record) {
      if (isValidZip(z) && record.city.toLowerCase().trim() == target) {
        matchedZips.add(z);
      }
    });

    final result = matchedZips.toList()..sort();
    return result;
  }

  /// 5. Area Code → City
  /// Returns all cities served by an area code (deduplicated & sorted ascending).
  List<String> lookupCityFromAreaCode(String areaCode) {
    final cleanCode = cleanAreaCode(areaCode);
    if (cleanCode == null) return const [];

    final records = areaCodeData[cleanCode];
    if (records == null || records.isEmpty) return const [];

    final cities = records.map((r) => r.city).toSet().toList()..sort();
    return cities;
  }

  /// 6. City → Area Code
  /// Returns all area codes serving a given city (deduplicated & sorted ascending).
  List<String> lookupAreaCodesFromCity(String city) {
    final target = city.toLowerCase().trim();
    if (target.isEmpty) return const [];

    final matchedCodes = <String>{};

    areaCodeData.forEach((code, records) {
      if (isValidAreaCode(code)) {
        for (final r in records) {
          if (r.city.toLowerCase().trim() == target) {
            matchedCodes.add(code);
            break;
          }
        }
      }
    });

    final result = matchedCodes.toList()..sort();
    return result;
  }

  // =========================================================================
  // HELPER METHODS
  // =========================================================================

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
      for (final code in entry.areaCodes) {
        addAreaCodeRecord(AreaCodeRecord(
          areaCode: code,
          city: entry.city,
          state: entry.state,
        ));
      }
    }
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    var current = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString());
        current = StringBuffer();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString());
    return result;
  }
}
