/// FILE: lib/modules/lookup/services/lookup_db_service.dart
import '../../../core/data/asset_importer.dart';
import '../../../core/db/app_database.dart';
import '../data/zip_seed_data.dart';
import '../models/lookup_models.dart';
import '../models/zip_entry.dart';

/// Offline ZIP / city / state / county / area-code / region / timezone /
/// lat-lng lookup backed by SQLite.
class LookupDbService {
  static const _table = 'lookup';

  Future<void> ensureSeeded() async {
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
  }

  /// Extracts clean 5-digit ZIP string from input (e.g. "17111-1234" -> "17111", "00501" -> "00501", "2108" -> "02108").
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

  /// ZIP → city/state/county/area code(s). Supports exact 5-digit, ZIP+4, padded, and prefix searches.
  Future<List<ZipEntry>> searchByZip(String zip) async {
    final trimmed = zip.trim();
    if (trimmed.isEmpty) return [];

    final db = await AppDatabase.instance.database;
    final cleanZip = _sanitizeZip(trimmed);

    // Build SQL query matching raw input, sanitized 5-digit padded string, or ZIP+4 base
    final whereClause = StringBuffer('zip LIKE ? OR zip LIKE ?');
    final args = <String>['$trimmed%', '$cleanZip%'];

    // Handle city name fallback if non-numeric
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

    // Fallback: search in-memory seed dataset
    return zipSeedData
        .where((e) =>
            e.zip == cleanZip ||
            e.zip.startsWith(cleanZip) ||
            e.zip.startsWith(trimmed))
        .toList();
  }

  /// City/county → ZIP list (returns city, state, county, area code, region per row).
  Future<List<ZipEntry>> searchByCity(String city) async {
    final trimmed = city.trim();
    if (trimmed.isEmpty) return [];
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

    final cityLower = trimmed.toLowerCase();
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
    final db = await AppDatabase.instance.database;

    final queryStr = trimmed.isNotEmpty ? trimmed : rawTrimmed;
    final rows = await db.query(
      _table,
      where: 'areaCode LIKE ? OR zip LIKE ? OR city LIKE ?',
      whereArgs: ['%$queryStr%', '$queryStr%', '%$queryStr%'],
      limit: 100,
    );
    final results = rows.map(ZipEntry.fromMap).toList();
    if (results.isNotEmpty) return results;

    return zipSeedData
        .where((e) => e.areaCode.contains(queryStr) || e.zip.startsWith(queryStr))
        .toList();
  }

  /// Autocomplete suggestions tailored by LookupMode.
  Future<List<String>> suggest(String query, {LookupMode? mode, int limit = 10}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    final db = await AppDatabase.instance.database;

    final suggestions = <String>{};

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
      if (suggestions.isEmpty) {
        for (final entry in zipSeedData) {
          if (entry.zip.startsWith(trimmed) || entry.zip.startsWith(cleanZip)) {
            suggestions.add('${entry.zip} (${entry.city}, ${entry.state})');
          }
        }
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
      if (suggestions.isEmpty) {
        final cLower = cityPart.toLowerCase();
        for (final entry in zipSeedData) {
          if (entry.city.toLowerCase().contains(cLower)) {
            suggestions.add('${entry.city}, ${entry.state}');
          }
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
    } else {
      final rows = await db.query(
        _table,
        columns: ['zip', 'city', 'state', 'areaCode'],
        where: 'zip LIKE ? OR city LIKE ? OR areaCode LIKE ?',
        whereArgs: ['$trimmed%', '%$trimmed%', '%$trimmed%'],
        limit: limit * 2,
      );
      for (final row in rows) {
        suggestions.add('${row['city']}, ${row['state']}');
        suggestions.add(row['zip'] as String);
        for (final code in (row['areaCode'] as String? ?? '').split(',')) {
          if (code.isNotEmpty) suggestions.add(code);
        }
      }
    }

    return suggestions.take(limit).toList();
  }
}
