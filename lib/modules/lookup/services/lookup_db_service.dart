/// FILE: lib/modules/lookup/services/lookup_db_service.dart
import '../../../core/data/asset_importer.dart';
import '../../../core/db/app_database.dart';
import '../data/zip_seed_data.dart';
import '../models/lookup_models.dart';
import '../models/zip_entry.dart';
import 'lookup_service.dart';

/// Offline ZIP / city / state / county / area-code / region / timezone /
/// lat-lng lookup backed by SQLite with in-memory service fallback for Web.
class LookupDbService {
  static const _table = 'lookup';
  final LookupService _inMemoryService = LookupService();

  Future<void> ensureSeeded() async {
    try {
      await _inMemoryService.ensureInitialized();
    } catch (_) {}

    try {
      final db = await AppDatabase.instance.database;
      final rows = await db.query(_table, columns: ['COUNT(*) as c']);
      final count = (rows.first['c'] as int?) ?? 0;
      if (count < 1000) {
        try {
          await AssetImporter.importLookupData(db);
        } catch (_) {
          if (count == 0) {
            final batch = db.batch();
            for (final entry in zipSeedData) {
              batch.insert(_table, entry.toMap());
            }
            await batch.commit(noResult: true);
          }
        }
      }
    } catch (_) {}
  }

  String _sanitizeZip(String raw) {
    final trimmed = raw.trim();
    if (trimmed.contains('-')) {
      final base = trimmed.split('-').first.trim();
      final digits = base.replaceAll(RegExp(r'[^\d]'), '');
      return digits.length <= 5 ? digits.padLeft(5, '0') : digits;
    }
    final cleanDigits = trimmed.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanDigits.isNotEmpty && cleanDigits.length <= 5) {
      return cleanDigits.padLeft(5, '0');
    }
    return trimmed;
  }

  /// ZIP → city/state/county/area code(s).
  Future<List<ZipEntry>> searchByZip(String zip) async {
    final trimmed = zip.trim();
    if (trimmed.isEmpty) return [];

    final cleanZip = _sanitizeZip(trimmed);

    try {
      final db = await AppDatabase.instance.database;
      final whereClause = StringBuffer('zip LIKE ? OR zip LIKE ?');
      final args = <String>['$trimmed%', '$cleanZip%'];

      if (RegExp(r'[a-zA-Z]').hasMatch(trimmed)) {
        final cityPart = trimmed.split(',').first.trim();
        whereClause.write(' OR city LIKE ?');
        args.add('%$cityPart%');
      }

      final rows = await db.query(
        _table,
        where: whereClause.toString(),
        whereArgs: args,
        limit: 100,
      );
      final results = rows.map(ZipEntry.fromMap).toList();
      if (results.isNotEmpty) return results;
    } catch (_) {}

    // Ensure in-memory dataset is initialized if SQLite returns 0 rows on Web
    if (!_inMemoryService.isInitialized) {
      await _inMemoryService.ensureInitialized();
    }

    // Fallback 1: Query in-memory LookupService map (prefix or exact match)
    final memRecord = _inMemoryService.zipData[cleanZip] ??
        _inMemoryService.zipData[trimmed] ??
        _inMemoryService.zipData.values.firstWhere(
          (r) => r.zip.startsWith(cleanZip) || r.zip.startsWith(trimmed),
          orElse: () => const ZipRecord(zip: '', city: '', state: ''),
        );

    if (memRecord.zip.isNotEmpty) {
      final areaCodes = _inMemoryService.lookupAreaCodesFromZip(memRecord.zip);
      return [
        ZipEntry(
          zip: memRecord.zip,
          city: memRecord.city,
          state: memRecord.state,
          county: memRecord.county,
          areaCodes: areaCodes,
          region: [memRecord.state],
          timezone: memRecord.timezone,
          lat: memRecord.lat,
          lng: memRecord.lng,
        )
      ];
    }

    // Fallback 2: Search in-memory zipSeedData
    return zipSeedData
        .where((e) =>
            e.zip == cleanZip ||
            e.zip.startsWith(cleanZip) ||
            e.zip.startsWith(trimmed))
        .toList();
  }

  /// City/county → ZIP list.
  Future<List<ZipEntry>> searchByCity(String city) async {
    final trimmed = city.trim();
    if (trimmed.isEmpty) return [];

    try {
      final db = await AppDatabase.instance.database;
      List<Map<String, dynamic>> rows;
      if (trimmed.contains(',')) {
        final parts = trimmed.split(',');
        final cityPart = parts[0].trim();
        final statePart = parts[1].trim();
        rows = await db.query(
          _table,
          where: '(city LIKE ? OR county LIKE ?) AND state LIKE ?',
          whereArgs: ['%$cityPart%', '%$cityPart%', '%$statePart%'],
          limit: 100,
        );
      } else {
        rows = await db.query(
          _table,
          where: 'city LIKE ? OR county LIKE ? OR state LIKE ?',
          whereArgs: ['%$trimmed%', '%$trimmed%', '%$trimmed%'],
          limit: 100,
        );
      }
      final results = rows.map(ZipEntry.fromMap).toList();
      if (results.isNotEmpty) return results;
    } catch (_) {}

    if (!_inMemoryService.isInitialized) {
      await _inMemoryService.ensureInitialized();
    }

    final cityLower = trimmed.toLowerCase();
    final memZips = _inMemoryService.lookupZipsFromCity(trimmed);
    if (memZips.isNotEmpty) {
      final list = <ZipEntry>[];
      for (final z in memZips) {
        final rec = _inMemoryService.zipData[z];
        if (rec != null) {
          list.add(ZipEntry(
            zip: rec.zip,
            city: rec.city,
            state: rec.state,
            county: rec.county,
            areaCodes: _inMemoryService.lookupAreaCodesFromZip(rec.zip),
            region: [rec.state],
            timezone: rec.timezone,
            lat: rec.lat,
            lng: rec.lng,
          ));
        }
      }
      if (list.isNotEmpty) return list;
    }

    return zipSeedData
        .where((e) =>
            e.city.toLowerCase().contains(cityLower) ||
            (e.county != null && e.county!.toLowerCase().contains(cityLower)) ||
            e.state.toLowerCase() == cityLower)
        .toList();
  }

  /// Area code → city/state/ZIP/region.
  Future<List<ZipEntry>> searchByAreaCode(String areaCode) async {
    final trimmed = areaCode.trim().split(' ').first.replaceAll(RegExp(r'[^\d]'), '');
    final rawTrimmed = areaCode.trim();
    if (trimmed.isEmpty && rawTrimmed.isEmpty) return [];

    final queryStr = trimmed.isNotEmpty ? trimmed : rawTrimmed;

    try {
      final db = await AppDatabase.instance.database;
      final rows = await db.query(
        _table,
        where: 'areaCode LIKE ? OR zip LIKE ? OR city LIKE ?',
        whereArgs: ['%$queryStr%', '$queryStr%', '%$queryStr%'],
        limit: 100,
      );
      final results = rows.map(ZipEntry.fromMap).toList();
      if (results.isNotEmpty) return results;
    } catch (_) {}

    if (!_inMemoryService.isInitialized) {
      await _inMemoryService.ensureInitialized();
    }

    final memCity = _inMemoryService.lookupCityFromAreaCode(queryStr);
    if (memCity != null) {
      final parts = memCity.split(',');
      final cName = parts[0].trim();
      final sName = parts.length > 1 ? parts[1].trim() : '';
      return [
        ZipEntry(
          zip: queryStr,
          city: cName,
          state: sName,
          areaCodes: [queryStr],
          region: [sName],
        )
      ];
    }

    return zipSeedData
        .where((e) => e.areaCode.contains(queryStr) || e.zip.startsWith(queryStr))
        .toList();
  }

  /// Autocomplete suggestions tailored by LookupMode.
  Future<List<String>> suggest(String query, {LookupMode? mode, int limit = 10}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final suggestions = <String>{};

    try {
      final db = await AppDatabase.instance.database;
      if (mode == LookupMode.byZip) {
        final cleanZip = _sanitizeZip(trimmed);
        final rows = await db.query(
          _table,
          columns: ['zip', 'city', 'state'],
          where: 'zip LIKE ? OR zip LIKE ?',
          whereArgs: ['$trimmed%', '$cleanZip%'],
          limit: limit * 2,
        );
        for (final r in rows) {
          suggestions.add('${r['zip']} (${r['city']}, ${r['state']})');
        }
      } else if (mode == LookupMode.byCity) {
        final cityPart = trimmed.split(',').first.trim();
        final rows = await db.query(
          _table,
          columns: ['city', 'county', 'state'],
          where: 'city LIKE ? OR county LIKE ? OR state LIKE ?',
          whereArgs: ['%$cityPart%', '%$cityPart%', '%$cityPart%'],
          limit: limit * 2,
        );
        for (final r in rows) {
          suggestions.add('${r['city']}, ${r['state']}');
          final county = r['county'] as String?;
          if (county != null && county.isNotEmpty) {
            suggestions.add('$county, ${r['state']}');
          }
        }
      } else if (mode == LookupMode.byAreaCode) {
        final cleanInput = trimmed.replaceAll(RegExp(r'[^\d]'), '');
        final queryStr = cleanInput.isNotEmpty ? cleanInput : trimmed;
        final rows = await db.query(
          _table,
          columns: ['areaCode', 'city', 'state'],
          where: 'areaCode LIKE ?',
          whereArgs: ['%$queryStr%'],
          limit: limit * 2,
        );
        for (final r in rows) {
          final codes = (r['areaCode'] as String? ?? '').split(',');
          for (final code in codes) {
            if (code.contains(queryStr)) {
              suggestions.add('$code (${r['city']}, ${r['state']})');
            }
          }
        }
      }
    } catch (_) {}

    if (suggestions.isNotEmpty) {
      return suggestions.take(limit).toList();
    }

    if (!_inMemoryService.isInitialized) {
      await _inMemoryService.ensureInitialized();
    }

    // In-Memory Suggestion Fallbacks for Web
    final cleanZip = _sanitizeZip(trimmed);
    if (mode == LookupMode.byZip) {
      _inMemoryService.zipData.forEach((z, rec) {
        if (z.startsWith(trimmed) || z.startsWith(cleanZip)) {
          suggestions.add('$z (${rec.city}, ${rec.state})');
        }
      });
      for (final entry in zipSeedData) {
        if (entry.zip.startsWith(trimmed) || entry.zip.startsWith(cleanZip)) {
          suggestions.add('${entry.zip} (${entry.city}, ${entry.state})');
        }
      }
    } else if (mode == LookupMode.byCity) {
      final cityPart = trimmed.split(',').first.trim().toLowerCase();
      _inMemoryService.zipData.forEach((z, rec) {
        if (rec.city.toLowerCase().contains(cityPart)) {
          suggestions.add('${rec.city}, ${rec.state}');
        }
      });
      for (final entry in zipSeedData) {
        if (entry.city.toLowerCase().contains(cityPart)) {
          suggestions.add('${entry.city}, ${entry.state}');
        }
      }
    } else if (mode == LookupMode.byAreaCode) {
      final queryStr = trimmed.replaceAll(RegExp(r'[^\d]'), '');
      _inMemoryService.areaCodeData.forEach((code, list) {
        if (code.contains(queryStr)) {
          for (final a in list) {
            suggestions.add('$code (${a.city}, ${a.state})');
          }
        }
      });
    }

    return suggestions.take(limit).toList();
  }
}
