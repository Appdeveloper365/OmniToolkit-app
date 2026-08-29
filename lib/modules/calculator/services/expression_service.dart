/// FILE: lib/modules/calculator/services/expression_service.dart
import 'dart:math' as math;

import 'package:math_expressions/math_expressions.dart';

/// Evaluates simple and scientific arithmetic expressions typed by the user
/// in an editable expression field. Supports +, -, *, /, ^, parentheses and
/// functions like sin, cos, tan, log, ln, sqrt.
class ExpressionService {
  final _parser = GrammarParser();

  double evaluate(String expression) {
    if (expression.trim().isEmpty) return 0;
    final sanitized = expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('π', '(3.141592653589793)')
        .replaceAll('%', '/100');

    final exp = _parser.parse(sanitized);
    final context = ContextModel();
    final result = exp.evaluate(EvaluationType.REAL, context);
    if (result is num) return result.toDouble();
    throw const FormatException('Invalid expression');
  }

  /// Trig helpers operating in degrees, used by the scientific keypad.
  double sinDeg(double degrees) => math.sin(degrees * math.pi / 180);
  double cosDeg(double degrees) => math.cos(degrees * math.pi / 180);
  double tanDeg(double degrees) => math.tan(degrees * math.pi / 180);
  double log10(double value) => math.log(value) / math.ln10;
  double ln(double value) => math.log(value);
  double sqrtOf(double value) => math.sqrt(value);
}
