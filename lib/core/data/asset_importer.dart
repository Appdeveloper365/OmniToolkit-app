import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';

/// Loads bundled datasets once so first launch is deterministic and offline.
class AssetImporter {
  static Future<void> importFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final db = await AppDatabase.instance.database;
    if (await _needsImport(db, prefs, 'holidaysImported', 'holidays')) {
      final data = await _loadList('assets/data/holidays.json');
      final batch = db.batch();
      for (final entry in data) {
        batch.insert('holidays', {
          'date': entry['date'],
          'name': entry['name'],
          'country': entry['country'],
        });
      }
      await batch.commit(noResult: true);
      await prefs.setBool('holidaysImported', true);
    }
    
    final lookupRows = await db.rawQuery('SELECT COUNT(*) as c FROM lookup');
    if ((lookupRows.first['c'] as int? ?? 0) < 1000) {
      await importLookupData(db);
      await prefs.setBool('lookupImported', true);
    }

    if (await _needsImport(db, prefs, 'radioImported', 'radio_streams')) {
      final data = await _loadList('assets/data/radio_streams.json');
      final batch = db.batch();
      for (final entry in data) {
        final url = (entry['url'] ?? entry['url_resolved'] ?? '') as String;
        if (!url.startsWith('https://')) continue;
        batch.insert('radio_streams', {
          'name': entry['name'],
          'url': url,
          'codec': entry['codec'] ?? 'MP3',
        });
      }
      await batch.commit(noResult: true);
      await prefs.setBool('radioImported', true);
    }
  }

  static Future<void> importLookupData(Database db) async {
    final rows = await db.rawQuery('SELECT COUNT(*) as c FROM lookup');
    final count = (rows.first['c'] as int?) ?? 0;
    if (count >= 1000) return;

    await db.delete('lookup');

    final zipMap = <String, Map<String, dynamic>>{};

    // 1. Load lookup_data.json
    try {
      final jsonList = await _loadList('assets/data/lookup_data.json');
      for (final entry in jsonList) {
        final zip = (entry['zip'] as String?)?.trim();
        if (zip == null || zip.isEmpty) continue;
        final cleanZ = zip.padLeft(5, '0');
        zipMap[cleanZ] = {
          'zip': cleanZ,
          'city': (entry['city'] as String?)?.trim() ?? '',
          'state': (entry['state'] as String?)?.trim() ?? '',
          'county': (entry['county'] as String?)?.trim(),
          'areaCode': _joinField(entry['area_code'] ?? entry['areaCode']),
          'region': _joinField(entry['region']),
          'timezone': (entry['timezone'] as String?)?.trim(),
          'lat': (entry['lat'] as num?)?.toDouble(),
          'lng': (entry['lng'] as num?)?.toDouble(),
        };
      }
    } catch (e) {
      debugPrint('[AssetImporter] Error parsing lookup_data.json: $e');
    }

    // 2. Load curated_us_zips.csv
    try {
      final csvString = await rootBundle.loadString('assets/data/curated_us_zips.csv');
      final lines = csvString.split('\n');
      final startIdx = (lines.isNotEmpty && lines.first.startsWith('zip,')) ? 1 : 0;
      for (var i = startIdx; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        final parts = _parseCsvLine(line);
        if (parts.length >= 3) {
          final rawZip = parts[0].replaceAll('"', '').trim();
          if (rawZip.isEmpty) continue;
          final cleanZ = rawZip.padLeft(5, '0');
          final city = parts[1].replaceAll('"', '').trim();
          final state = parts[2].replaceAll('"', '').trim();
          final county = parts.length > 3 ? parts[3].replaceAll('"', '').trim() : null;
          final timezone = parts.length > 4 ? parts[4].replaceAll('"', '').trim() : null;
          final lat = parts.length > 5 ? double.tryParse(parts[5].replaceAll('"', '')) : null;
          final lng = parts.length > 6 ? double.tryParse(parts[6].replaceAll('"', '')) : null;

          if (zipMap.containsKey(cleanZ)) {
            final existing = zipMap[cleanZ]!;
            if ((existing['county'] == null || (existing['county'] as String).isEmpty) &&
                county != null &&
                county.isNotEmpty) {
              existing['county'] = county;
            }
            if (existing['timezone'] == null && timezone != null && timezone.isNotEmpty) {
              existing['timezone'] = timezone;
            }
            if (existing['lat'] == null) existing['lat'] = lat;
            if (existing['lng'] == null) existing['lng'] = lng;
          } else {
            zipMap[cleanZ] = {
              'zip': cleanZ,
              'city': city,
              'state': state,
              'county': county?.isEmpty == true ? null : county,
              'areaCode': null,
              'region': null,
              'timezone': timezone?.isEmpty == true ? null : timezone,
              'lat': lat,
              'lng': lng,
            };
          }
        }
      }
    } catch (e) {
      debugPrint('[AssetImporter] Error parsing curated_us_zips.csv: $e');
    }

    if (zipMap.isEmpty) return;

    // Batch insert into SQLite / IndexedDB in chunks of 500 to prevent Web IndexedDB transaction timeout
    final records = zipMap.values.toList();
    const chunkSize = 500;
    for (var i = 0; i < records.length; i += chunkSize) {
      final end = (i + chunkSize < records.length) ? i + chunkSize : records.length;
      final chunk = records.sublist(i, end);
      final batch = db.batch();
      for (final record in chunk) {
        batch.insert('lookup', record);
      }
      await batch.commit(noResult: true);
    }
  }

  static List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final current = StringBuffer();
    var inQuotes = false;
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

  static Future<bool> _needsImport(
    Database db,
    SharedPreferences prefs,
    String flag,
    String table,
  ) async {
    if (!(prefs.getBool(flag) ?? false)) return true;
    final rows = await db.rawQuery('SELECT COUNT(*) as c FROM $table');
    return (rows.first['c'] as int) == 0;
  }

  static Future<List<Map<String, dynamic>>> _loadList(String asset) async {
    final raw = await rootBundle.loadString(asset);
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Dataset must contain a JSON array');
    }
    return decoded.cast<Map<String, dynamic>>();
  }

  static String? _joinField(dynamic value) {
    if (value == null) return null;
    if (value is List) return value.map((e) => e.toString()).join(',');
    return value.toString();
  }
}
