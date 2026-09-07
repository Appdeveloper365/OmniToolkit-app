/// FILE: lib/modules/calculator/widgets/calculator_keypad_grid.dart
import 'package:flutter/material.dart';

import 'premium_calculator_button.dart';

/// Declarative spec for one key in a [CalculatorKeypadGrid] row.
class CalcKeySpec {
  const CalcKeySpec({
    required this.label,
    required this.onTap,
    this.role = CalcKeyRole.numberLight,
    this.fontSize = 20,
    this.semanticsLabel,
  });

  final String label;
  final VoidCallback onTap;
  final CalcKeyRole role;
  final double fontSize;
  final String? semanticsLabel;
}

/// Lays out rows of [CalcKeySpec] as a touch-friendly square grid: every key
/// is a square cell (min 48px to fit on small mobile viewports without scrolling),
/// with 6-8px spacing, centered, and capped to a maximum width.
class CalculatorKeypadGrid extends StatelessWidget {
  const CalculatorKeypadGrid({
    super.key,
    required this.rows,
    this.maxWidth = 420,
    this.minCellSize = 48,
    this.spacing = 8,
  });

  final List<List<CalcKeySpec>> rows;
  final double maxWidth;
  final double minCellSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final columns = rows.isEmpty ? 0 : rows.map((r) => r.length).reduce((a, b) => a > b ? a : b);
    if (columns == 0) return const SizedBox.shrink();

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth < maxWidth ? constraints.maxWidth : maxWidth;
          final cellSize = ((width - spacing * (columns - 1)) / columns)
              .clamp(minCellSize, double.infinity)
              .toDouble();
          final gridWidth = cellSize * columns + spacing * (columns - 1);

          return SizedBox(
            width: gridWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var r = 0; r < rows.length; r++) ...[
                  if (r > 0) SizedBox(height: spacing),
                  Row(
                    children: [
                      for (var c = 0; c < rows[r].length; c++) ...[
                        if (c > 0) SizedBox(width: spacing),
                        SizedBox(
                          width: cellSize,
                          height: cellSize,
                          child: PremiumCalculatorButton(
                            label: rows[r][c].label,
                            role: rows[r][c].role,
                            fontSize: rows[r][c].fontSize,
                            semanticsLabel: rows[r][c].semanticsLabel,
                            onTap: rows[r][c].onTap,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
