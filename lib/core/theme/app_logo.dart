/// FILE: lib/core/theme/app_logo.dart
import 'package:flutter/material.dart';

/// OmniToolkit logo: a calendar outline with a clock inside and a small
/// calculator badge in the top-right corner. Drawn entirely with
/// [CustomPainter] so no external image assets are required.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AppLogoPainter(
          calendarColor: scheme.primary,
          clockColor: scheme.onPrimary,
          badgeColor: scheme.secondary,
        ),
      ),
    );
  }
}

class _AppLogoPainter extends CustomPainter {
  _AppLogoPainter({
    required this.calendarColor,
    required this.clockColor,
    required this.badgeColor,
  });

  final Color calendarColor;
  final Color clockColor;
  final Color badgeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Calendar body.
    final calendarRect = Rect.fromLTWH(w * 0.05, h * 0.15, w * 0.9, h * 0.8);
    final calendarPaint = Paint()..color = calendarColor;
    final calendarRRect =
        RRect.fromRectAndRadius(calendarRect, Radius.circular(w * 0.08));
    canvas.drawRRect(calendarRRect, calendarPaint);

    // Calendar header strip.
    final headerRect = Rect.fromLTWH(w * 0.05, h * 0.15, w * 0.9, h * 0.16);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        headerRect,
        topLeft: Radius.circular(w * 0.08),
        topRight: Radius.circular(w * 0.08),
      ),
      Paint()..color = calendarColor.withValues(alpha: 0.6),
    );

    // Binder rings.
    final ringPaint = Paint()..color = calendarColor.withValues(alpha: 0.9);
    canvas.drawCircle(Offset(w * 0.3, h * 0.15), w * 0.03, ringPaint);
    canvas.drawCircle(Offset(w * 0.7, h * 0.15), w * 0.03, ringPaint);

    // Clock face inside calendar body.
    final clockCenter = Offset(w * 0.5, h * 0.62);
    final clockRadius = w * 0.28;
    canvas.drawCircle(clockCenter, clockRadius, Paint()..color = clockColor);
    canvas.drawCircle(
      clockCenter,
      clockRadius,
      Paint()
        ..color = calendarColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.02,
    );

    // Clock hands.
    final handPaint = Paint()
      ..color = calendarColor
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      clockCenter,
      clockCenter + Offset(0, -clockRadius * 0.6),
      handPaint,
    );
    canvas.drawLine(
      clockCenter,
      clockCenter + Offset(clockRadius * 0.4, clockRadius * 0.1),
      handPaint,
    );

    // Calculator badge, top-right corner.
    final badgeRect = Rect.fromLTWH(w * 0.62, h * 0.0, w * 0.36, h * 0.36);
    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeRect, Radius.circular(w * 0.06)),
      Paint()..color = badgeColor,
    );
    final dotPaint = Paint()..color = calendarColor;
    const gridPositions = [
      [0.7, 0.09],
      [0.8, 0.09],
      [0.89, 0.09],
      [0.7, 0.18],
      [0.8, 0.18],
      [0.89, 0.18],
    ];
    for (final pos in gridPositions) {
      canvas.drawCircle(
        Offset(w * pos[0], h * pos[1]),
        w * 0.015,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AppLogoPainter oldDelegate) => false;
}
