import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/modules/calculator/services/expression_service.dart';

void main() {
  final service = ExpressionService();

  test('evaluate basic arithmetic', () {
    expect(service.evaluate('2 + 3'), 5);
    expect(service.evaluate('7 × 8'), 56);
    expect(service.evaluate('10 ÷ 2'), 5);
    expect(service.evaluate('2 + 3 * 4'), 14);
    expect(service.evaluate('10 %'), 0.1);
  });

  test('evaluate scientific functions', () {
    expect(service.evaluate('sqrt(16)'), 4);
    expect(service.evaluate('2^3'), 8);
    expect(service.evaluate('ln(2.718281828459045)'), closeTo(1.0, 1e-5));
  });
}
