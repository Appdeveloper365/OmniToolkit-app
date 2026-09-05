/// FILE: lib/modules/calendar/widgets/calendar_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/holiday_record.dart';
import '../models/note_model.dart';
import '../providers/calendar_provider.dart';

/// Brown/Orange highlight used for calendar cells that contain at least one note.
const Color _notedCellColor = Color(0xFF8B4513); // SaddleBrown / Orange-Brown

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
    final isToday = _isSameDay(date, DateTime.now());
    final hasNote = notedDates.contains(dateKey);
    final holidaysForDay = holidayLabels[dateKey] ?? const <HolidayRecord>[];
    final scheme = Theme.of(context).colorScheme;

    // Styling logic: Note dates are Brown/Orange with white readable text.
    final backgroundColor = hasNote
        ? _notedCellColor
        : (isSelected
            ? scheme.primary
            : (isSecondary ? scheme.secondaryContainer : Colors.transparent));

    final foregroundColor = hasNote
        ? Colors.white
        : (isSelected
            ? scheme.onPrimary
            : (isSecondary ? scheme.onSecondaryContainer : null));

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isSelected
                ? BorderSide(color: scheme.primary, width: 2.5)
                : (isSecondary
                    ? BorderSide(color: scheme.secondary, width: 2)
                    : (isToday
                        ? BorderSide(color: scheme.primary, width: 1.5)
                        : BorderSide.none)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              ref.read(selectedDateProvider.notifier).state = date;
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
                          fontWeight: (hasNote || isSelected || isSecondary) ? FontWeight.bold : FontWeight.normal,
                          fontSize: hasNote ? 10 : null,
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
}
