/// FILE: lib/modules/calculator/services/date_math_service.dart

/// Calendar-aware year/month/day breakdown of the span between two dates,
/// e.g. used for both "months/years between" and "calculate age".
class DateBreakdown {
  const DateBreakdown({required this.years, required this.months, required this.days});
  final int years;
  final int months;
  final int days;
}

/// Pure date-math helpers backing the Date Calculator tab. Kept dependency
/// free (no BuildContext / widgets) so it is trivially unit-testable.
class DateMathService {
  /// Whole days between [start] and [end], always >= 0 regardless of order.
  int daysBetween(DateTime start, DateTime end) {
    final a = DateTime(start.year, start.month, start.day);
    final b = DateTime(end.year, end.month, end.day);
    return b.difference(a).inDays.abs();
  }

  /// Returns (weeks, remainderDays) for the span between [start] and [end].
  (int weeks, int days) weeksBetween(DateTime start, DateTime end) {
    final total = daysBetween(start, end);
    return (total ~/ 7, total % 7);
  }

  /// Calendar-accurate years/months/days between two dates (order-independent).
  DateBreakdown calendarBreakdown(DateTime start, DateTime end) {
    var from = start.isBefore(end) ? start : end;
    var to = start.isBefore(end) ? end : start;
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);

    var years = to.year - from.year;
    var months = to.month - from.month;
    var days = to.day - from.day;

    if (days < 0) {
      months -= 1;
      final prevMonth = DateTime(to.year, to.month, 0); // last day of previous month
      days += prevMonth.day;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }
    return DateBreakdown(years: years, months: months, days: days);
  }

  /// Whole months between two dates (calendar-aware), ignoring the leftover days.
  int monthsBetween(DateTime start, DateTime end) {
    final b = calendarBreakdown(start, end);
    return b.years * 12 + b.months;
  }

  /// Whole years between two dates (calendar-aware), ignoring leftover months/days.
  int yearsBetween(DateTime start, DateTime end) => calendarBreakdown(start, end).years;

  DateTime addDays(DateTime date, int days) => DateTime(date.year, date.month, date.day).add(Duration(days: days));

  DateTime subtractDays(DateTime date, int days) => addDays(date, -days);

  /// Age as of [asOf] (defaults handled by caller) for a given [birthDate].
  DateBreakdown age(DateTime birthDate, DateTime asOf) => calendarBreakdown(birthDate, asOf);

  /// Count of Mon-Fri business days between [start] and [end], inclusive of
  /// both endpoints, excluding Saturday/Sunday.
  int businessDaysBetween(DateTime start, DateTime end) {
    var from = start.isBefore(end) ? start : end;
    var to = start.isBefore(end) ? end : start;
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);

    var count = 0;
    var cursor = from;
    while (!cursor.isAfter(to)) {
      if (cursor.weekday != DateTime.saturday && cursor.weekday != DateTime.sunday) {
        count++;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return count;
  }
}