/// FILE: lib/modules/calculator/providers/calculator_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/date_math_service.dart';
import '../services/expression_service.dart';
import '../services/unit_converter_service.dart';

final expressionServiceProvider = Provider((ref) => ExpressionService());
final unitConverterServiceProvider = Provider((ref) => UnitConverterService());
final dateMathServiceProvider = Provider((ref) => DateMathService());

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

/// Immutable snapshot of the calculator's current session. The session
/// (expression, live result, and history) is intentionally never persisted -
/// it exists only for the lifetime of the widget tree, matching the
/// "session-only memory" requirement.
class CalculatorSessionState {
  const CalculatorSessionState({
    this.expression = '',
    this.result = '',
    this.history = const [],
    this.justEvaluated = false,
    this.memory = 0,
    this.hasMemory = false,
  });

  final String expression;
  final String result;
  final List<String> history;
  final bool justEvaluated;
  final double memory;
  final bool hasMemory;

  CalculatorSessionState copyWith({
    String? expression,
    String? result,
    List<String>? history,
    bool? justEvaluated,
    double? memory,
    bool? hasMemory,
  }) {
    return CalculatorSessionState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
      history: history ?? this.history,
      justEvaluated: justEvaluated ?? this.justEvaluated,
      memory: memory ?? this.memory,
      hasMemory: hasMemory ?? this.hasMemory,
    );
  }
}

const _digits = '0123456789';
const _operators = '+-×÷^%';

/// Drives the Standard and Scientific calculator tabs. Both share one
/// notifier instance per [CalculatorSessionNotifier] provider so switching
/// tabs never loses the in-progress calculation.
class CalculatorSessionNotifier extends StateNotifier<CalculatorSessionState> {
  CalculatorSessionNotifier(this._service) : super(const CalculatorSessionState());

  final ExpressionService _service;

  void _recomputeLiveResult() {
    final expr = state.expression.trim();
    if (expr.isEmpty) {
      state = state.copyWith(result: '');
      return;
    }
    try {
      final value = _service.evaluate(expr);
      state = state.copyWith(result: formatCalculatorResult(value));
    } catch (_) {
      state = state.copyWith(result: '');
    }
  }

  /// Appends a digit, operator, decimal point, or parenthesis token.
  void input(String token) {
    if (state.justEvaluated) {
      final startingFresh = token.length == 1 && (_digits.contains(token) || token == '.' || token == '(');
      if (startingFresh) {
        state = state.copyWith(expression: token, justEvaluated: false, history: const []);
      } else {
        // Continue the chain from the previous result (e.g. "15" then "+").
        state = state.copyWith(expression: state.expression + token, justEvaluated: false);
      }
    } else {
      state = state.copyWith(expression: state.expression + token);
    }
    _recomputeLiveResult();
  }

  void backspace() {
    if (state.expression.isEmpty) return;
    state = state.copyWith(
      expression: state.expression.substring(0, state.expression.length - 1),
      justEvaluated: false,
    );
    _recomputeLiveResult();
  }

  void clearAll() {
    // AC resets the expression/result/history but intentionally preserves
    // the memory register (M+/M-/MR/MC), matching hardware calculators.
    state = CalculatorSessionState(memory: state.memory, hasMemory: state.hasMemory);
  }

  /// Toggles the sign of the trailing number in the expression.
  void toggleSign() {
    final expr = state.expression;
    if (expr.isEmpty) {
      state = state.copyWith(expression: '-');
      return;
    }
    final match = RegExp(r'(\d+\.?\d*)$').firstMatch(expr);
    if (match == null) return;
    final numberStart = match.start;
    final prefix = expr.substring(0, numberStart);
    final number = match.group(0)!;
    String updated;
    if (prefix.endsWith('-') && (numberStart == 1 || _isOperatorChar(prefix[numberStart - 2]))) {
      // Remove the existing leading minus for this operand.
      updated = '${prefix.substring(0, numberStart - 1)}$number';
    } else if (numberStart == 0) {
      updated = '-$number';
    } else if (_isOperatorChar(prefix[prefix.length - 1])) {
      updated = '$prefix-$number';
    } else {
      updated = expr;
    }
    state = state.copyWith(expression: updated, justEvaluated: false);
    _recomputeLiveResult();
  }

  bool _isOperatorChar(String c) => _operators.contains(c);

  void equals() {
    final expr = state.expression.trim();
    if (expr.isEmpty) return;
    try {
      final value = _service.evaluate(expr);
      final formatted = formatCalculatorResult(value);
      if (formatted == 'Error') {
        state = state.copyWith(result: 'Error');
        return;
      }
      final entry = '$expr = $formatted';
      state = state.copyWith(
        expression: formatted,
        result: formatted,
        history: [...state.history, entry],
        justEvaluated: true,
      );
    } catch (_) {
      state = state.copyWith(result: 'Error');
    }
  }

  /// Applies a unary scientific function (sin, cos, sqrt, x², x³, 1/x,
  /// factorial, |x|, ...) to the current expression's value, then starts a
  /// fresh chain from the computed result - matching hardware scientific
  /// calculator behavior.
  void applyUnary(String label, double Function(double) fn) {
    final expr = state.expression.trim().isEmpty ? '0' : state.expression.trim();
    try {
      final input = _service.evaluate(expr);
      final value = fn(input);
      final formatted = formatCalculatorResult(value);
      final entry = '$label($expr) = $formatted';
      state = state.copyWith(
        expression: formatted,
        result: formatted,
        history: [...state.history, entry],
        justEvaluated: true,
      );
    } catch (_) {
      state = state.copyWith(result: 'Error');
    }
  }

  void memoryClear() => state = state.copyWith(memory: 0, hasMemory: false);

  void memoryRecall() {
    if (!state.hasMemory) return;
    input(formatCalculatorResult(state.memory));
  }

  void memoryAdd() {
    final expr = state.expression.trim().isEmpty ? state.result : state.expression;
    final value = double.tryParse(expr) ?? _tryEvaluate(expr);
    state = state.copyWith(memory: state.memory + value, hasMemory: true);
  }

  void memorySubtract() {
    final expr = state.expression.trim().isEmpty ? state.result : state.expression;
    final value = double.tryParse(expr) ?? _tryEvaluate(expr);
    state = state.copyWith(memory: state.memory - value, hasMemory: true);
  }

  double _tryEvaluate(String expr) {
    try {
      return _service.evaluate(expr);
    } catch (_) {
      return 0;
    }
  }
}

final calculatorSessionProvider =
    StateNotifierProvider<CalculatorSessionNotifier, CalculatorSessionState>((ref) {
  return CalculatorSessionNotifier(ref.watch(expressionServiceProvider));
});