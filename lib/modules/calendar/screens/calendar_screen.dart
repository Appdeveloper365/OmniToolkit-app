/// FILE: lib/modules/calendar/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/note_model.dart';
import '../providers/calendar_provider.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/note_dialog.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  static final _timeFormat = DateFormat('hh:mm a');

  Future<void> _openNoteDialog(BuildContext context, WidgetRef ref, {NoteModel? existing}) async {
    final date = ref.read(selectedDateProvider);
    final result = await showDialog<NoteModel>(
      context: context,
      builder: (_) => NoteDialog(date: date, existing: existing),
    );
    if (result == null) return;
    final controller = ref.read(notesControllerProvider);
    if (existing != null) {
      await controller.updateNote(result);
    } else {
      await controller.addNote(result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final notesAsync = ref.watch(notesForSelectedDateProvider);
    final controller = ref.read(notesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar'), actions: [
        IconButton(icon: const Icon(Icons.event_note), tooltip: 'Holiday info',
          onPressed: () async {
            final holidays = await ref.read(holidaysForSelectedDateProvider.future);
            if (!context.mounted) return;
            final text = holidays.isEmpty
                ? 'No holiday on this date.'
                : holidays.map((h) => h.country == null ? h.name : '${h.name} (${h.country})').join('\n');
            showDialog(context: context, builder: (_) => AlertDialog(
              title: const Text('Holidays and important days'),
              content: Text(text),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
            ));
          }),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteDialog(context, ref),
        tooltip: 'Add note',
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CalendarGrid(),
          const Divider(height: 32),
          Text(
            DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          // Note preview panel: notes are hidden inside the calendar cells
          // themselves and are only revealed here once a date is tapped.
          notesAsync.when(
            data: (notes) {
              if (notes.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No notes for this date.'),
                );
              }
              return Column(
                children: notes
                    .map((note) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.note),
                            title: Text(note.noteText),
                            subtitle: note.createdAt != null
                                ? Text(_timeFormat.format(note.createdAt!))
                                : null,
                            trailing: PopupMenuButton(
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: 'edit', child: Text('Edit')),
                                PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _openNoteDialog(context, ref, existing: note);
                                } else if (value == 'delete' && note.id != null) {
                                  controller.deleteNote(note.id!);
                                }
                              },
                            ),
                          ),
                        ))
                    .toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Failed to load notes: $err'),
          ),
        ],
      ),
    );
  }
}