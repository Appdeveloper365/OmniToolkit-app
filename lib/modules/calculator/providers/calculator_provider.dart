/// FILE: lib/modules/calculator/providers/calculator_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/expression_service.dart';
import '../services/unit_converter_service.dart';

final expressionServiceProvider = Provider((ref) => ExpressionService());
final unitConverterServiceProvider = Provider((ref) => UnitConverterService());

/// Editable expression text shared by the simple + scientific calculators.
final expressionInputProvider = StateProvider<String>((ref) => '');

/// Latest evaluated result (or error message) for the expression field.
final expressionResultProvider = StateProvider<String>((ref) => '');
