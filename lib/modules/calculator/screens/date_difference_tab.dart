/// FILE: lib/modules/calculator/screens/date_difference_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/calculator_provider.dart';

enum _DateMode { difference, addSubtract, age, businessDays }

/// The "Date Calculator" tab: days/weeks/months/years between dates, add or
/// subtract days from a date, age calculation, and a business-days
/// calculator that excludes weekends.
class DateDifferenceTab extends ConsumerStatefulWidget {
  const DateDifferenceTab({super.key});

  @override
  ConsumerState<DateDifferenceTab> createState() => _DateDifferenceTabState();
}

class _DateDifferenceTabState extends ConsumerState<DateDifferenceTab> {
  _DateMode _mode = _DateMode.difference;

  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(days: 30));

  DateTime _base = DateTime.now();
  final _daysController = TextEditingController(text: '45');
  bool _isAdd = true;

  DateTime _birthDate = DateTime(DateTime.now().year - 25, 1, 1);

  static final _format = DateFormat('EEE, MMM d, yyyy');

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(DateTime initial, ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (picked != null) onPicked(picked);
  }

  Widget _dateTile(String label, DateTime date, ValueChanged<DateTime> onPicked) {
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: Text(_format.format(date)),
        trailing: const Icon(Icons.calendar_today),
        onTap: () => _pickDate(date, onPicked),
      ),
    );
  }

  Widget _resultCard(BuildContext context, List<Widget> children) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }

  Widget _buildDifference(BuildContext context) {
    final service = ref.watch(dateMathServiceProvider);
    final days = service.daysBetween(_start, _end);
    final (weeks, remainderDays) = service.weeksBetween(_start, _end);
    final months = service.monthsBetween(_start, _end);
    final years = service.yearsBetween(_start, _end);
    final breakdown = service.calendarBreakdown(_start, _end);

    return Column(
      children: [
        _dateTile('Start date', _start, (d) => setState(() => _start = d)),
        _dateTile('End date', _end, (d) => setState(() => _end = d)),
        const SizedBox(height: 16),
        _resultCard(context, [
          Text('Days Between', style: Theme.of(context).textTheme.labelLarge),
          Text('$days Days', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text('Weeks Between', style: Theme.of(context).textTheme.labelLarge),
          Text('$weeks Weeks, $remainderDays Day${remainderDays == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text('Months Between', style: Theme.of(context).textTheme.labelLarge),
          Text('$months Months', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text('Years Between', style: Theme.of(context).textTheme.labelLarge),
          Text('$years Years', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text('≈ ${breakdown.years}y ${breakdown.months}m ${breakdown.days}d',
              style: Theme.of(context).textTheme.bodyMedium),
        ]),
      ],
    );
  }

  Widget _buildAddSubtract(BuildContext context) {
    final service = ref.watch(dateMathServiceProvider);
    final days = int.tryParse(_daysController.text) ?? 0;
    final result = _isAdd ? service.addDays(_base, days) : service.subtractDays(_base, days);

    return Column(
      children: [
        _dateTile('Base date', _base, (d) => setState(() => _base = d)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Add')),
                  ButtonSegment(value: false, label: Text('Subtract')),
                ],
                selected: {_isAdd},
                onSelectionChanged: (s) => setState(() => _isAdd = s.first),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _daysController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Number of days'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        _resultCard(context, [
          Text('Result Date', style: Theme.of(context).textTheme.labelLarge),
          Text(_format.format(result), style: Theme.of(context).textTheme.headlineSmall),
        ]),
      ],
    );
  }

  Widget _buildAge(BuildContext context) {
    final service = ref.watch(dateMathServiceProvider);
    final age = service.age(_birthDate, DateTime.now());

    return Column(
      children: [
        _dateTile('Birth date', _birthDate, (d) => setState(() => _birthDate = d)),
        const SizedBox(height: 16),
        _resultCard(context, [
          Text('Current Age', style: Theme.of(context).textTheme.labelLarge),
          Text('${age.years} Years, ${age.months} Months, ${age.days} Days',
              style: Theme.of(context).textTheme.headlineSmall),
        ]),
      ],
    );
  }

  Widget _buildBusinessDays(BuildContext context) {
    final service = ref.watch(dateMathServiceProvider);
    final businessDays = service.businessDaysBetween(_start, _end);
    final totalDays = service.daysBetween(_start, _end) + 1;

    return Column(
      children: [
        _dateTile('Start date', _start, (d) => setState(() => _start = d)),
        _dateTile('End date', _end, (d) => setState(() => _end = d)),
        const SizedBox(height: 16),
        _resultCard(context, [
          Text('Business Days (excludes weekends)', style: Theme.of(context).textTheme.labelLarge),
          Text('$businessDays Business Days', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Out of $totalDays total calendar days', style: Theme.of(context).textTheme.bodyMedium),
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<_DateMode>(
            segments: const [
              ButtonSegment(value: _DateMode.difference, label: Text('Difference'), icon: Icon(Icons.compare_arrows)),
              ButtonSegment(value: _DateMode.addSubtract, label: Text('Add / Subtract'), icon: Icon(Icons.exposure)),
              ButtonSegment(value: _DateMode.age, label: Text('Age'), icon: Icon(Icons.cake_outlined)),
              ButtonSegment(value: _DateMode.businessDays, label: Text('Business Days'), icon: Icon(Icons.business_center_outlined)),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() => _mode = s.first),
          ),
        ),
        const SizedBox(height: 16),
        switch (_mode) {
          _DateMode.difference => _buildDifference(context),
          _DateMode.addSubtract => _buildAddSubtract(context),
          _DateMode.age => _buildAge(context),
          _DateMode.businessDays => _buildBusinessDays(context),
        },
      ],
    );
  }
}