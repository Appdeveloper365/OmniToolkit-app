import 'package:flutter_test/flutter_test.dart';
import 'package:omnitoolkit/modules/calculator/services/date_math_service.dart';

void main() {
  final service = DateMathService();

  test('daysBetween matches spec example: 09/01/2026 to 09/30/2026 = 29 days', () {
    expect(service.daysBetween(DateTime(2026, 9, 1), DateTime(2026, 9, 30)), 29);
  });

  test('weeksBetween returns weeks and remainder days', () {
    final (weeks, days) = service.weeksBetween(DateTime(2026, 9, 1), DateTime(2026, 9, 30));
    expect(weeks, 4);
    expect(days, 1);
  });

  test('addDays matches spec example: 09/01/2026 + 45 days = 10/16/2026', () {
    final result = service.addDays(DateTime(2026, 9, 1), 45);
    expect(result, DateTime(2026, 10, 16));
  });

  test('subtractDays reverses addDays', () {
    final added = service.addDays(DateTime(2026, 9, 1), 45);
    expect(service.subtractDays(added, 45), DateTime(2026, 9, 1));
  });

  test('monthsBetween and yearsBetween are calendar-aware', () {
    expect(service.monthsBetween(DateTime(2024, 1, 15), DateTime(2026, 3, 15)), 26);
    expect(service.yearsBetween(DateTime(2024, 1, 15), DateTime(2026, 3, 15)), 2);
  });

  test('calendarBreakdown / age computes years, months, days correctly', () {
    final breakdown = service.calendarBreakdown(DateTime(2000, 6, 15), DateTime(2026, 9, 4));
    expect(breakdown.years, 26);
    expect(breakdown.months, 2);
    expect(breakdown.days, 20);
  });

  test('businessDaysBetween excludes weekends', () {
    // Tue Sep 1, 2026 through Wed Sep 30, 2026 (30 calendar days inclusive).
    final businessDays = service.businessDaysBetween(DateTime(2026, 9, 1), DateTime(2026, 9, 30));
    expect(businessDays, 22);
  });
}