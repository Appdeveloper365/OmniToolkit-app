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
        // Fallback for widget testing environments without rootBundle
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

  /// ZIP → city/state/area code(s).
  Future<List<ZipEntry>> searchByZip(String zip) async {
    final trimmed = zip.trim();
    if (trimmed.isEmpty) return [];
    final db = await AppDatabase.instance.database;

    // Handle sanitized/padded 5-digit zip if numeric (e.g. 2101 -> 02101)
    String? padded;
    final cleanInput = trimmed.split(' ').first.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanInput.isNotEmpty && cleanInput.length <= 5) {
      padded = cleanInput.padLeft(5, '0');
    }

    final whereClause = StringBuffer('zip LIKE ?');
    final args = <String>['$trimmed%'];

    if (padded != null && padded != trimmed) {
      whereClause.write(' OR zip LIKE ?');
      args.add('$padded%');
    }

    // Fallback search by city if non-numeric string (e.g. user selected city from autocomplete)
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
    return rows.map(ZipEntry.fromMap).toList();
  }

  /// City/county → ZIP list (also returns state/area code/region per row).
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
    return rows.map(ZipEntry.fromMap).toList();
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
    return rows.map(ZipEntry.fromMap).toList();
  }

  /// Autocomplete suggestions tailored by LookupMode.
  Future<List<String>> suggest(String query, {LookupMode? mode, int limit = 10}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    final db = await AppDatabase.instance.database;

    final suggestions = <String>{};

    if (mode == LookupMode.byZip) {
      final cleanInput = trimmed.replaceAll(RegExp(r'[^\d]'), '');
      final padded = cleanInput.length <= 5 && cleanInput.isNotEmpty ? cleanInput.padLeft(5, '0') : null;
      final args = ['$trimmed%'];
      var where = 'zip LIKE ?';
      if (padded != null && padded != trimmed) {
        where += ' OR zip LIKE ?';
        args.add('$padded%');
      }
      final rows = await db.query(
        _table,
        columns: ['zip', 'city', 'state'],
        where: where,
        whereArgs: args,
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

