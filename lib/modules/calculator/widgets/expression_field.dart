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

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(expressionResultProvider);
    final external = ref.watch(expressionInputProvider);

    // Keep controller in sync when input is changed via keypad or text field
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
          onChanged: (value) {
            ref.read(expressionInputProvider.notifier).state = value;
          },
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
