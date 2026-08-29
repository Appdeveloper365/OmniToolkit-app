/// FILE: lib/modules/calendar/models/holiday_record.dart

/// A holiday/observance day loaded from the offline `holidays` SQLite table.
class HolidayRecord {
  const HolidayRecord({required this.date, required this.name, this.country});

  final DateTime date;
  final String name;
  final String? country;

  /// Short label truncated for display inside calendar date cells.
  String get shortLabel => name.length <= 14 ? name : '${name.substring(0, 13)}…';

  factory HolidayRecord.fromMap(Map<String, dynamic> map) => HolidayRecord(
        date: DateTime.parse(map['date'] as String),
        name: map['name'] as String,
        country: map['country'] as String?,
      );
}
