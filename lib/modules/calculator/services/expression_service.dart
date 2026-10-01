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
    final sanitized = _closeOpenParens(
      _normalizeLeadingDecimalPoint(
        expression
            .replaceAll('×', '*')
            .replaceAll('÷', '/')
            .replaceAll('π', '(3.141592653589793)')
            .replaceAll(
              RegExp(r'(?<![a-zA-Z])e(?![a-zA-Z])'),
              '(2.718281828459045)',
            )
            .replaceAll('%', '/100'),
      ),
    );

    final exp = _parser.parse(sanitized);
    final context = ContextModel();
    final result = exp.evaluate(EvaluationType.REAL, context);
    if (result is num) return result.toDouble();
    throw const FormatException('Invalid expression');
  }

  /// Gives a `.` that starts a number its missing leading zero.
  ///
  /// The parser rejects a bare `.5` or `2*.5`, so pressing `.` before any
  /// digit left the display blank instead of showing 0.5. Hardware calculators
  /// treat a leading decimal point as zero, so `0` is inserted before any `.`
  /// that is not already preceded by a digit.
  static String _normalizeLeadingDecimalPoint(String expression) {
    final buffer = StringBuffer();
    for (var i = 0; i < expression.length; i++) {
      final c = expression[i];
      if (c == '.' && (i == 0 || !_isDigit(expression[i - 1]))) {
        buffer.write('0');
      }
      buffer.write(c);
    }
    return buffer.toString();
  }

  static bool _isDigit(String c) => c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39;

  /// Appends the `)` that [expression] is missing, and discards any surplus
  /// closing brackets left dangling at the end.
  ///
  /// The scientific keypad's nth-root key enters `^(1/` and relies on the
  /// user typing the closing bracket, so `16 n-th-root 2 =` used to evaluate
  /// to Error. Auto-closing matches hardware calculators and lets the result
  /// appear live as soon as the exponent is entered.
  static String _closeOpenParens(String expression) {
    var open = 0;
    for (var i = 0; i < expression.length; i++) {
      final c = expression[i];
      if (c == '(') {
        open++;
      } else if (c == ')') {
        if (open == 0) {
          // Stray ')' with nothing to close: drop it and everything after.
          return expression.substring(0, i);
        }
        open--;
      }
    }
    if (open <= 0) return expression;
    return '$expression${')' * open}';
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