/// FILE: lib/modules/calendar/services/calendar_db_service.dart
import '../../../core/db/app_database.dart';
import '../models/note_model.dart';

/// CRUD access to the `calendar_notes` SQLite table.
class CalendarDbService {
  Future<int> insertNote(NoteModel note) async {
    final db = await AppDatabase.instance.database;
    return db.insert('calendar_notes', note.toMap());
  }

  Future<int> updateNote(NoteModel note) async {
    final db = await AppDatabase.instance.database;
    return db.update(
      'calendar_notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await AppDatabase.instance.database;
    return db.delete('calendar_notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<NoteModel>> notesForDate(DateTime date) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'calendar_notes',
      where: 'date = ?',
      whereArgs: [NoteModel.dateKey(date)],
      orderBy: 'id ASC',
    );
    return rows.map(NoteModel.fromMap).toList();
  }

  /// Returns all distinct date keys ('yyyy-MM-dd') that have at least one note,
  /// used to highlight days in the calendar grid.
  Future<Set<String>> datesWithNotes(int year, int month) async {
    final db = await AppDatabase.instance.database;
    final prefix = '$year-${month.toString().padLeft(2, '0')}';
    final rows = await db.query(
      'calendar_notes',
      columns: ['DISTINCT date'],
      where: 'date LIKE ?',
      whereArgs: ['$prefix%'],
    );
    return rows.map((r) => r['date'] as String).toSet();
  }

  Future<int> insertHoliday(String title, DateTime date, {String? description}) {
    return insertNote(NoteModel(title: title, date: date, description: description));
  }
}
