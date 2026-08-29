/// FILE: lib/modules/calculator/screens/unit_converter_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/calculator_provider.dart';

class UnitConverterTab extends ConsumerStatefulWidget {
  const UnitConverterTab({super.key});

  @override
  ConsumerState<UnitConverterTab> createState() => _UnitConverterTabState();
}

class _UnitConverterTabState extends ConsumerState<UnitConverterTab> {
  late String _category;
  late String _fromUnit;
  late String _toUnit;
  final _inputController = TextEditingController(text: '1');
  double? _result;

  @override
  void initState() {
    super.initState();
    final service = ref.read(unitConverterServiceProvider);
    _category = service.categories.first;
    final units = service.unitsFor(_category);
    _fromUnit = units[0];
    _toUnit = units.length > 1 ? units[1] : units[0];
    _convert();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _convert() {
    final service = ref.read(unitConverterServiceProvider);
    final value = double.tryParse(_inputController.text) ?? 0;
    setState(() {
      _result = service.convert(_category, _fromUnit, _toUnit, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(unitConverterServiceProvider);
    final units = service.unitsFor(_category);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          initialValue: _category,
          decoration: const InputDecoration(labelText: 'Category'),
          items: service.categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            final newUnits = service.unitsFor(value);
            setState(() {
              _category = value;
              _fromUnit = newUnits[0];
              _toUnit = newUnits.length > 1 ? newUnits[1] : newUnits[0];
            });
            _convert();
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _inputController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          decoration: const InputDecoration(labelText: 'Value'),
          onChanged: (_) => _convert(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _fromUnit,
                decoration: const InputDecoration(labelText: 'From'),
                items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _fromUnit = value);
                  _convert();
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: () {
                setState(() {
                  final tmp = _fromUnit;
                  _fromUnit = _toUnit;
                  _toUnit = tmp;
                });
                _convert();
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _toUnit,
                decoration: const InputDecoration(labelText: 'To'),
                items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _toUnit = value);
                  _convert();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _result == null ? '—' : '${_result!.toStringAsFixed(4)} $_toUnit',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
      ],
    );
  }
}
