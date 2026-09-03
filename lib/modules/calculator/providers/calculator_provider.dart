import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/expression_service.dart';
import '../services/unit_converter_service.dart';

final expressionServiceProvider = Provider((ref) => ExpressionService());
final unitConverterServiceProvider = Provider((ref) => UnitConverterService());

/// Editable expression text shared by the simple + scientific calculators.
final expressionInputProvider = StateProvider<String>((ref) => '');

/// Live result calculated automatically from [expressionInputProvider].
final expressionResultProvider = Provider<String>((ref) {
  final input = ref.watch(expressionInputProvider).trim();
  if (input.isEmpty) return '';
  try {
    final result = ref.read(expressionServiceProvider).evaluate(input);
    return formatCalculatorResult(result);
  } catch (_) {
    return '';
  }
});

String formatCalculatorResult(double value) {
  if (value.isNaN || value.isInfinite) return 'Error';
  if (value == value.roundToDouble() && value.abs() < 1e15) {
    return value.round().toString();
  }
  return value
      .toStringAsPrecision(10)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
