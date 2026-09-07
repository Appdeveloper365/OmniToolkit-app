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
    final map = note.toMap()..remove('id');
    return db.update(
      'calendar_notes',
      map,
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await AppDatabase.instance.database;
    return db.delete('calendar_notes', where: 'id = ?', whereArgs: [id]);
  }

  /// Notes for [date], ordered chronologically by creation time.
  Future<List<NoteModel>> notesForDate(DateTime date) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'calendar_notes',
      where: 'note_date = ?',
      whereArgs: [NoteModel.dateKey(date)],
      orderBy: 'created_at ASC, id ASC',
    );
    return rows.map(NoteModel.fromMap).toList();
  }

  /// Returns all distinct date keys ('yyyy-MM-dd') that have at least one note,
  /// used to highlight days in the calendar grid. Runs a single lightweight
  /// query scoped to the visible month so the whole calendar does not need
  /// to reload after every note edit.
  Future<Set<String>> datesWithNotes(int year, int month) async {
    final db = await AppDatabase.instance.database;
    final prefix = '$year-${month.toString().padLeft(2, '0')}';
    final rows = await db.query(
      'calendar_notes',
      columns: ['DISTINCT note_date'],
      where: 'note_date LIKE ?',
      whereArgs: ['$prefix%'],
    );
    return rows.map((r) => r['note_date'] as String).toSet();
  }

  Future<int> insertHoliday(String title, DateTime date, {String? description}) {
    final text = description == null || description.isEmpty ? title : '$title\n$description';
    return insertNote(NoteModel(date: date, noteText: text));
  }
}