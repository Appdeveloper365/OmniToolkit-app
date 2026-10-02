/// FILE: lib/modules/calendar/widgets/calendar_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/holiday_record.dart';
import '../models/note_model.dart';
import '../providers/calendar_provider.dart';
import 'note_dialog.dart';

/// Orange highlight used for calendar cells that contain at least one note.
// Using primaryContainer with orange tint for better theme integration and accessibility.
const Color _notedCellColor = Color(0xFFFFB74D); // Orange tint of primaryContainer

class CalendarGrid extends ConsumerWidget {
  const CalendarGrid({super.key});

  static const _weekdayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  static final _cellDateFormat = DateFormat('MM/dd/yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(visibleMonthProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final secondaryDate = ref.watch(secondaryDateProvider);

    final notesAsync = ref.watch(datesWithNotesProvider);
    final notedDates = notesAsync.valueOrNull ?? <String>{};
    final holidayLabelsAsync = ref.watch(holidayLabelsProvider);
    final holidayLabels = holidayLabelsAsync.valueOrNull ?? <String, List<HolidayRecord>>{};

    final firstOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = (firstOfMonth.weekday - DateTime.monday) % 7;
    final totalCells = leadingBlanks + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => ref.read(visibleMonthProvider.notifier).state =
                  DateTime(month.year, month.month - 1),
            ),
            Text(
              _monthLabel(month),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => ref.read(visibleMonthProvider.notifier).state =
                  DateTime(month.year, month.month + 1),
            ),
          ],
        ),
        Row(
          children: _weekdayLabels
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ))
              .toList(),
        ),
        const Divider(height: 8),
        for (var row = 0; row < rowCount; row++)
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                Expanded(
                  child: _buildCell(
                    context,
                    ref,
                    row * 7 + col,
                    leadingBlanks,
                    daysInMonth,
                    month,
                    selectedDate,
                    secondaryDate,
                    notedDates,
                    holidayLabels,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildCell(
    BuildContext context,
    WidgetRef ref,
    int cellIndex,
    int leadingBlanks,
    int daysInMonth,
    DateTime month,
    DateTime selectedDate,
    DateTime? secondaryDate,
    Set<String> notedDates,
    Map<String, List<HolidayRecord>> holidayLabels,
  ) {
    final dayNumber = cellIndex - leadingBlanks + 1;
    if (dayNumber < 1 || dayNumber > daysInMonth) {
      return const AspectRatio(aspectRatio: 1, child: SizedBox());
    }
    final date = DateTime(month.year, month.month, dayNumber);
    final dateKey = NoteModel.dateKey(date);

    final isSelected = _isSameDay(date, selectedDate);
    final isSecondary = secondaryDate != null && _isSameDay(date, secondaryDate);
    final hasNote = notedDates.contains(dateKey);
    final holidaysForDay = holidayLabels[dateKey] ?? const <HolidayRecord>[];
    final scheme = Theme.of(context).colorScheme;

    // Priority: selected day > secondary selection > noted cell > empty
    final backgroundColor = isSelected
        ? scheme.primary
        : (isSecondary ? scheme.secondaryContainer : (hasNote ? _notedCellColor : Colors.transparent));

    // Text color based on background for readability
    final foregroundColor = isSelected
        ? scheme.onPrimary
        : (isSecondary ? scheme.onSecondaryContainer : (hasNote ? scheme.onPrimary : null));

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Material(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected
                  ? scheme.primary
                  : (isSecondary ? scheme.secondary : Colors.grey.withValues(alpha: 0.3)),
              width: isSelected ? 3.0 : 1.5,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              // If date has notes, show note options instead of just selecting.
              if (hasNote) {
                _showNoteOptions(context, date, ref);
              } else {
                ref.read(selectedDateProvider.notifier).state = date;
              }
            },
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hasNote ? _cellDateFormat.format(date) : '$dayNumber',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: foregroundColor,
                          fontWeight: FontWeight.bold,
                          fontSize: hasNote ? 10 : 16,
                        ),
                      ),
                      if (holidaysForDay.isNotEmpty)
                        Text(
                          holidaysForDay.length > 1
                              ? '${holidaysForDay.first.shortLabel} +'
                              : holidaysForDay.first.shortLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: foregroundColor ??
                                (holidaysForDay.first.country == 'US' ? Colors.blue : Colors.green),
                          ),
                        ),
                    ],
                  ),
                ),
                if (hasNote)
                  const Positioned(
                    top: 2,
                    right: 2,
                    child: Icon(Icons.note_rounded, size: 12, color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthLabel(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showNoteOptions(BuildContext context, DateTime date, WidgetRef ref) {
    ref.read(selectedDateProvider.notifier).state = date;
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _NoteOptionsSheet(date: date),
    );
  }
}

/// Bottom sheet shown when tapping a day that has notes: lets the user
/// add a new note, or edit/delete existing ones for that day.
class _NoteOptionsSheet extends ConsumerWidget {
  const _NoteOptionsSheet({required this.date});

  static final _timeFormat = DateFormat('hh:mm a');
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesForSelectedDateProvider);
    final controller = ref.read(notesControllerProvider);
    final theme = Theme.of(context);

    Future<void> openDialog({NoteModel? existing}) async {
      final result = await showDialog<NoteModel>(
        context: context,
        builder: (_) => NoteDialog(date: date, existing: existing),
      );
      if (result == null) return;
      if (existing != null) {
        await controller.updateNote(result);
      } else {
        await controller.addNote(result);
      }
    }

    Future<void> confirmDelete(int id) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete note?'),
          content: const Text('This note will be permanently removed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed == true) await controller.deleteNote(id);
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Notes for ${CalendarGrid._cellDateFormat.format(date)}',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => openDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Note'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            notesAsync.when(
              data: (notes) {
                if (notes.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No notes for this date yet.'),
                  );
                }
                return Column(
                  children: notes
                      .map((note) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              note.noteText,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: note.createdAt != null
                                ? Text(
                                    'Saved at ${_timeFormat.format(note.createdAt!)}',
                                  )
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: 'Edit',
                                  onPressed: () => openDialog(existing: note),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Delete',
                                  onPressed: note.id != null
                                      ? () => confirmDelete(note.id!)
                                      : null,
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Failed to load notes: $err'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
