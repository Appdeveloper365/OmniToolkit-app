/// FILE: lib/modules/calendar/services/holiday_db_service.dart
import '../../../core/db/app_database.dart';
import '../models/holiday_record.dart';

/// Reads holiday/observance-day data from the offline `holidays` SQLite
/// table (populated by `AssetImporter` from assets/data/holidays.json).
class HolidayDbService {
  /// Returns all holidays whose (month, day) falls within [month] of any
  /// year, keyed by 'yyyy-MM-dd' for the requested [year]/[month].
  Future<Map<String, List<HolidayRecord>>> holidaysForMonth(int year, int month) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('holidays');
    final result = <String, List<HolidayRecord>>{};
    for (final row in rows) {
      final record = HolidayRecord.fromMap(row);
      if (record.date.month != month) continue;
      final key = _dateKey(year, month, record.date.day);
      result.putIfAbsent(key, () => []).add(record);
    }
    return result;
  }

  Future<List<HolidayRecord>> forDate(DateTime date) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('holidays');
    return rows
        .map(HolidayRecord.fromMap)
        .where((h) => h.date.month == date.month && h.date.day == date.day)
        .toList();
  }

  String _dateKey(int year, int month, int day) =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}
