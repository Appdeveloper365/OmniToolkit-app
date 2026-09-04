/// FILE: lib/modules/calculator/widgets/calculator_body.dart
import 'package:flutter/material.dart';

/// The calculator's outer "hardware" shell: rounded corners, a premium
/// metallic/graphite gradient, and a soft elevated drop shadow. Keeps a
/// square-ish silhouette by capping its width, so it never stretches into a
/// landscape shape on wide screens.
class CalculatorBody extends StatelessWidget {
  const CalculatorBody({super.key, required this.child, this.maxWidth = 460});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF232427), Color(0xFF121214)] // Graphite black
                  : const [Color(0xFFE4E6EA), Color(0xFFC7CBD1)], // Silver gray
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.22),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}