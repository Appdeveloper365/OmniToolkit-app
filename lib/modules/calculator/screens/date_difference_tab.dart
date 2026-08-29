/// FILE: lib/modules/calculator/screens/date_difference_tab.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateDifferenceTab extends StatefulWidget {
  const DateDifferenceTab({super.key});

  @override
  State<DateDifferenceTab> createState() => _DateDifferenceTabState();
}

class _DateDifferenceTabState extends State<DateDifferenceTab> {
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(days: 30));

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (picked == null) return;
    setState(() => isStart ? _start = picked : _end = picked);
  }

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('EEE, MMM d, yyyy');
    final difference = _end.difference(_start);
    final totalDays = difference.inDays.abs();
    final years = totalDays ~/ 365;
    final remainingAfterYears = totalDays % 365;
    final months = remainingAfterYears ~/ 30;
    final days = remainingAfterYears % 30;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            title: const Text('Start date'),
            subtitle: Text(format.format(_start)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _pickDate(isStart: true),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text('End date'),
            subtitle: Text(format.format(_end)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _pickDate(isStart: false),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total difference', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Text('$totalDays days', style: Theme.of(context).textTheme.headlineSmall),
                Text('≈ $years years, $months months, $days days'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
