import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/modules/calculator/providers/calculator_provider.dart';

void main() {
  test('session builds an expression, evaluates it, and records history', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(calculatorSessionProvider.notifier);

    notifier.input('5');
    notifier.input('+');
    notifier.input('5');
    notifier.equals();

    final state = container.read(calculatorSessionProvider);
    expect(state.expression, '10');
    expect(state.result, '10');
    expect(state.history, ['5+5 = 10']);
  });

  test('continuing after a result keeps history (chained calculation)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(calculatorSessionProvider.notifier);

    notifier.input('5');
    notifier.input('+');
    notifier.input('5');
    notifier.equals(); // 10, history: [5+5 = 10]

    notifier.input('×');
    notifier.input('2');
    notifier.equals(); // 20, history should now have 2 entries

    final state = container.read(calculatorSessionProvider);
    expect(state.result, '20');
    expect(state.history, ['5+5 = 10', '10×2 = 20']);
  });

  test('starting a new calculation with a digit after a result clears history', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(calculatorSessionProvider.notifier);

    notifier.input('5');
    notifier.input('+');
    notifier.input('5');
    notifier.equals(); // 10

    notifier.input('2'); // brand new calculation

    final state = container.read(calculatorSessionProvider);
    expect(state.expression, '2');
    expect(state.history, isEmpty);
  });

  test('AC clears expression, result, and history', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(calculatorSessionProvider.notifier);

    notifier.input('5');
    notifier.input('+');
    notifier.input('5');
    notifier.equals();
    notifier.clearAll();

    final state = container.read(calculatorSessionProvider);
    expect(state.expression, '');
    expect(state.result, '');
    expect(state.history, isEmpty);
  });

  test('memory add/recall/clear round trip', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(calculatorSessionProvider.notifier);

    notifier.input('42');
    notifier.memoryAdd();
    notifier.clearAll();
    notifier.memoryRecall();

    var state = container.read(calculatorSessionProvider);
    expect(state.expression, '42');

    notifier.memoryClear();
    state = container.read(calculatorSessionProvider);
    expect(state.hasMemory, isFalse);
  });
}