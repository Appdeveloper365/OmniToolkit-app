import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/core/db/app_database.dart';
import 'package:omnitoolkit/modules/calendar/models/note_model.dart';
import 'package:omnitoolkit/modules/calendar/services/calendar_db_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late CalendarDbService dbService;
  final date = DateTime(2026, 9, 30);

  setUp(() async {
    dbService = CalendarDbService();
    final db = await AppDatabase.instance.database;
    await db.delete('calendar_notes');
  });

  group('CalendarDbService', () {
    test('insertNote persists a note linked to its date', () async {
      final id = await dbService.insertNote(NoteModel(date: date, noteText: 'Doctor appointment'));
      expect(id, greaterThan(0));

      final notes = await dbService.notesForDate(date);
      expect(notes, hasLength(1));
      expect(notes.first.noteText, equals('Doctor appointment'));
      expect(notes.first.date.year, equals(2026));
      expect(notes.first.date.month, equals(9));
      expect(notes.first.date.day, equals(30));
    });

    test('datesWithNotes reports the date key once a note exists, and stops once removed', () async {
      final id = await dbService.insertNote(NoteModel(date: date, noteText: 'Project review meeting'));

      var noted = await dbService.datesWithNotes(2026, 9);
      expect(noted, contains(NoteModel.dateKey(date)));

      await dbService.deleteNote(id);
      noted = await dbService.datesWithNotes(2026, 9);
      expect(noted, isNot(contains(NoteModel.dateKey(date))));
    });

    test('multiple notes for the same date are returned in chronological order', () async {
      final first = NoteModel(
        date: date,
        noteText: 'Doctor appointment',
        createdAt: DateTime(2026, 9, 30, 9, 15),
      );
      final second = NoteModel(
        date: date,
        noteText: 'Project review meeting',
        createdAt: DateTime(2026, 9, 30, 13, 30),
      );
      // Insert out of order to prove ordering comes from the query, not insert order.
      await dbService.insertNote(second);
      await dbService.insertNote(first);

      final notes = await dbService.notesForDate(date);
      expect(notes, hasLength(2));
      expect(notes.first.noteText, equals('Doctor appointment'));
      expect(notes.last.noteText, equals('Project review meeting'));
    });

    test('updateNote edits text while keeping the date highlighted', () async {
      final id = await dbService.insertNote(NoteModel(date: date, noteText: 'Original text'));
      final notes = await dbService.notesForDate(date);
      await dbService.updateNote(notes.first.copyWith(id: id, noteText: 'Updated text'));

      final updated = await dbService.notesForDate(date);
      expect(updated, hasLength(1));
      expect(updated.first.noteText, equals('Updated text'));

      final noted = await dbService.datesWithNotes(2026, 9);
      expect(noted, contains(NoteModel.dateKey(date)));
    });

    test('deleting the only note for a date removes it from datesWithNotes', () async {
      final id = await dbService.insertNote(NoteModel(date: date, noteText: 'Temporary note'));
      await dbService.deleteNote(id);

      final notes = await dbService.notesForDate(date);
      expect(notes, isEmpty);

      final noted = await dbService.datesWithNotes(2026, 9);
      expect(noted, isEmpty);
    });
  });
}