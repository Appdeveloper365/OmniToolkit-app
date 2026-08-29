/// FILE: lib/modules/calculator/widgets/expression_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/calculator_provider.dart';

/// Editable text field showing the current expression and its live result.
/// Shared between the simple and scientific calculator tabs.
class ExpressionField extends ConsumerStatefulWidget {
  const ExpressionField({super.key});

  @override
  ConsumerState<ExpressionField> createState() => _ExpressionFieldState();
}

class _ExpressionFieldState extends ConsumerState<ExpressionField> {
  late final _controller = TextEditingController(text: ref.read(expressionInputProvider));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _evaluate(String value) {
    ref.read(expressionInputProvider.notifier).state = value;
    try {
      final result = ref.read(expressionServiceProvider).evaluate(value);
      ref.read(expressionResultProvider.notifier).state = _formatResult(result);
    } catch (_) {
      ref.read(expressionResultProvider.notifier).state = value.trim().isEmpty ? '' : 'Error';
    }
  }

  String _formatResult(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsPrecision(10).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(expressionResultProvider);
    // keep controller in sync when input changed externally (keypad taps)
    final external = ref.watch(expressionInputProvider);
    if (_controller.text != external) {
      _controller.value = TextEditingValue(
        text: external,
        selection: TextSelection.collapsed(offset: external.length),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          onChanged: _evaluate,
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.headlineSmall,
          decoration: const InputDecoration(
            hintText: 'Enter expression, e.g. 2 + 3 * 4',
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            result,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: result == 'Error' ? Theme.of(context).colorScheme.error : null,
                ),
          ),
        ),
      ],
    );
  }
}
