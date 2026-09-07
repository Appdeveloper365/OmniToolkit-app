/// FILE: lib/modules/calendar/providers/calendar_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/holiday_record.dart';
import '../models/note_model.dart';
import '../services/calendar_db_service.dart';
import '../services/holiday_db_service.dart';

final calendarDbServiceProvider = Provider<CalendarDbService>((ref) => CalendarDbService());
final holidayDbServiceProvider = Provider<HolidayDbService>((ref) => HolidayDbService());

/// Month currently visible in the grid.
final visibleMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// Date currently selected by the user (Primary / Start date).
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Secondary date for Date Difference Calculator.
final secondaryDateProvider = StateProvider<DateTime?>((ref) => null);

/// Set of 'yyyy-MM-dd' date keys that have notes, for the visible month.
final datesWithNotesProvider = FutureProvider<Set<String>>((ref) async {
  final month = ref.watch(visibleMonthProvider);
  final service = ref.watch(calendarDbServiceProvider);
  return service.datesWithNotes(month.year, month.month);
});

/// Holidays/observance days for the visible month, keyed by 'yyyy-MM-dd',
/// sourced from the offline SQLite `holidays` table.
final holidayLabelsProvider = FutureProvider<Map<String, List<HolidayRecord>>>((ref) async {
  final month = ref.watch(visibleMonthProvider);
  final service = ref.watch(holidayDbServiceProvider);
  return service.holidaysForMonth(month.year, month.month);
});

/// Holidays/observance days for the currently selected date.
final holidaysForSelectedDateProvider = FutureProvider<List<HolidayRecord>>((ref) async {
  final date = ref.watch(selectedDateProvider);
  final service = ref.watch(holidayDbServiceProvider);
  return service.forDate(date);
});

/// Notes for the currently selected date.
final notesForSelectedDateProvider = FutureProvider<List<NoteModel>>((ref) async {
  final date = ref.watch(selectedDateProvider);
  final service = ref.watch(calendarDbServiceProvider);
  return service.notesForDate(date);
});

class NotesController {
  NotesController(this.ref);
  final Ref ref;

  Future<void> addNote(NoteModel note) async {
    await ref.read(calendarDbServiceProvider).insertNote(note);
    _refresh();
  }

  Future<void> updateNote(NoteModel note) async {
    await ref.read(calendarDbServiceProvider).updateNote(note);
    _refresh();
  }

  Future<void> deleteNote(int id) async {
    await ref.read(calendarDbServiceProvider).deleteNote(id);
    _refresh();
  }

  void _refresh() {
    ref.invalidate(notesForSelectedDateProvider);
    ref.invalidate(datesWithNotesProvider);
  }
}

final notesControllerProvider = Provider((ref) => NotesController(ref));
