/// FILE: lib/modules/calendar/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../calculator/services/date_math_service.dart';
import '../models/note_model.dart';
import '../providers/calendar_provider.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/note_dialog.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  static final _timeFormat = DateFormat('hh:mm a');
  static final _fullDateFormat = DateFormat('EEEE, MMMM d, yyyy'); // e.g. September 4, 2026
  static final _shortDateFormat = DateFormat('MM/dd/yyyy');
  static final _dateMathService = DateMathService();

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

  Future<void> _selectSecondaryDate(BuildContext context, WidgetRef ref) async {
    final current = ref.read(secondaryDateProvider) ?? ref.read(selectedDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      ref.read(secondaryDateProvider.notifier).state = picked;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final secondaryDate = ref.watch(secondaryDateProvider);
    final notesAsync = ref.watch(notesForSelectedDateProvider);
    final holidaysAsync = ref.watch(holidaysForSelectedDateProvider);
    final controller = ref.read(notesControllerProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar & Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Holidays & Observance Days',
            onPressed: () async {
              final holidays = await ref.read(holidaysForSelectedDateProvider.future);
              if (!context.mounted) return;
              final text = holidays.isEmpty
                  ? 'No public holiday or observance day on this date.'
                  : holidays.map((h) => h.country == null || h.country == 'INTL'
                      ? '• ${h.name} (International)'
                      : '• ${h.name} (${h.country})').join('\n');
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Holidays for ${_shortDateFormat.format(selectedDate)}'),
                  content: Text(text),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNoteDialog(context, ref),
        tooltip: 'Add note',
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('Add Note'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Calendar Grid Container
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: CalendarGrid(),
              ),
            ),
            const SizedBox(height: 16),

            // Selected Date Header Panel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fullDateFormat.format(selectedDate),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0284C7),
                    ),
                  ),
                  holidaysAsync.when(
                    data: (holidays) {
                      if (holidays.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          holidays.map((h) => h.country == 'INTL' ? '🌐 ${h.name}' : '🎉 ${h.name} (${h.country})').join(' • '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.amber[800],
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Notes Section
            notesAsync.when(
              data: (notes) {
                if (notes.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                    ),
                    child: const Center(
                      child: Text(
                        'No notes for this date. Tap "Add Note" to create one.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                return Column(
                  children: notes
                      .map((note) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFF8B4513),
                                child: Icon(Icons.note_rounded, color: Colors.white, size: 20),
                              ),
                              title: Text(note.noteText, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: note.createdAt != null
                                  ? Text('Saved at ${_timeFormat.format(note.createdAt!)}')
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

            const SizedBox(height: 24),

            // Built-in Date Difference Calculator Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.date_range_rounded, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Date Difference Calculator',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        if (secondaryDate != null)
                          TextButton(
                            onPressed: () => ref.read(secondaryDateProvider.notifier).state = null,
                            child: const Text('Clear Target'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start Date:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text(_shortDateFormat.format(selectedDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Target Date:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                InkWell(
                                  onTap: () => _selectSecondaryDate(context, ref),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          secondaryDate != null ? _shortDateFormat.format(secondaryDate) : 'Select Date',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: secondaryDate == null ? theme.colorScheme.primary : null,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.calendar_month, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    if (secondaryDate == null)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Tap "Select Date" above to calculate days, weeks, months, and years difference.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      _buildDifferenceResults(selectedDate, secondaryDate),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifferenceResults(DateTime start, DateTime end) {
    final days = _dateMathService.daysBetween(start, end);
    final (weeks, remDays) = _dateMathService.weeksBetween(start, end);
    final breakdown = _dateMathService.calendarBreakdown(start, end);

    return Column(
      children: [
        Row(
          children: [
            _ResultTile(label: 'Total Days', value: '$days Days'),
            _ResultTile(label: 'Weeks', value: '$weeks wks, $remDays d'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _ResultTile(label: 'Months & Days', value: '${breakdown.years * 12 + breakdown.months} mos, ${breakdown.days} d'),
            _ResultTile(label: 'Full Breakdown', value: '${breakdown.years}y ${breakdown.months}m ${breakdown.days}d'),
          ],
        ),
      ],
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
