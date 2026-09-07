/// FILE: lib/modules/calculator/services/expression_service.dart
import 'dart:math' as math;

import 'package:math_expressions/math_expressions.dart';

/// Evaluates simple and scientific arithmetic expressions typed by the user
/// in the calculator display. Supports +, -, *, /, ^, parentheses and
/// functions like sin, cos, tan, log, ln, sqrt.
class ExpressionService {
  final _parser = GrammarParser();

  double evaluate(String expression) {
    if (expression.trim().isEmpty) return 0;
    final sanitized = expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('π', '(3.141592653589793)')
        .replaceAll(RegExp(r'(?<![a-zA-Z])e(?![a-zA-Z])'), '(2.718281828459045)')
        .replaceAll('%', '/100');

    final exp = _parser.parse(sanitized);
    final context = ContextModel();
    final result = exp.evaluate(EvaluationType.REAL, context);
    if (result is num) return result.toDouble();
    throw const FormatException('Invalid expression');
  }

  // ---- Scientific helpers (operate on already-evaluated numeric values,
  // used by the scientific keypad's unary function buttons). Trig runs in
  // degrees to match how most handheld scientific calculators default. ----
  double sinDeg(double degrees) => math.sin(degrees * math.pi / 180);
  double cosDeg(double degrees) => math.cos(degrees * math.pi / 180);
  double tanDeg(double degrees) => math.tan(degrees * math.pi / 180);
  double asinDeg(double value) => math.asin(value) * 180 / math.pi;
  double acosDeg(double value) => math.acos(value) * 180 / math.pi;
  double atanDeg(double value) => math.atan(value) * 180 / math.pi;
  double log10(double value) => math.log(value) / math.ln10;
  double ln(double value) => math.log(value);
  double sqrtOf(double value) => math.sqrt(value);
  double square(double value) => value * value;
  double cube(double value) => value * value * value;
  double reciprocal(double value) => 1 / value;
  double absoluteValue(double value) => value.abs();
  double nthRoot(double value, double n) => math.pow(value, 1 / n).toDouble();
  double power(double base, double exponent) => math.pow(base, exponent).toDouble();

  double factorial(double value) {
    final n = value.round();
    if (n < 0 || value - n != 0) return double.nan;
    var result = 1.0;
    for (var i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }
}