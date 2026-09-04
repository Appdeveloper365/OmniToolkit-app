/// FILE: lib/modules/calculator/widgets/premium_calculator_button.dart
import 'package:flutter/material.dart';

/// Visual role of a calculator key, used to pick its gradient/color per the
/// premium 3D design + alternating key color spec.
enum CalcKeyRole {
  numberDark,
  numberLight,
  add,
  subtract,
  multiply,
  divide,
  equals,
  clear,
  delete,
  function,
  memory,
}

/// A single premium, touch-friendly calculator key: gradient fill, top
/// highlight / bottom shadow for a raised "hardware calculator" look, and an
/// inward-press animation (100-200ms) when tapped.
class PremiumCalculatorButton extends StatefulWidget {
  const PremiumCalculatorButton({
    super.key,
    required this.label,
    required this.onTap,
    this.role = CalcKeyRole.numberLight,
    this.fontSize = 22,
    this.semanticsLabel,
  });

  final String label;
  final VoidCallback onTap;
  final CalcKeyRole role;
  final double fontSize;
  final String? semanticsLabel;

  @override
  State<PremiumCalculatorButton> createState() => _PremiumCalculatorButtonState();
}

class _PremiumCalculatorButtonState extends State<PremiumCalculatorButton> {
  bool _pressed = false;

  List<Color> _gradientFor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (widget.role) {
      case CalcKeyRole.numberDark:
        return isDark ? const [Color(0xFF3A3A3D), Color(0xFF2A2A2C)] : const [Color(0xFF9E9E9E), Color(0xFF7C7C7C)];
      case CalcKeyRole.numberLight:
        return isDark ? const [Color(0xFF4C4C50), Color(0xFF3C3C3E)] : const [Color(0xFFE8E8E8), Color(0xFFCFCFCF)];
      case CalcKeyRole.add:
        return const [Color(0xFF4FA8FF), Color(0xFF1E76D8)];
      case CalcKeyRole.subtract:
        return const [Color(0xFFFFA85C), Color(0xFFE8792A)];
      case CalcKeyRole.multiply:
        return const [Color(0xFF6FDB7C), Color(0xFF2FA83F)];
      case CalcKeyRole.divide:
        return const [Color(0xFFC292FF), Color(0xFF8A3FE0)];
      case CalcKeyRole.equals:
        return const [Color(0xFFFFD86B), Color(0xFFE0A800)];
      case CalcKeyRole.clear:
        return const [Color(0xFFFF6B6B), Color(0xFFD53434)];
      case CalcKeyRole.delete:
        return const [Color(0xFFB33A3A), Color(0xFF7A1F1F)];
      case CalcKeyRole.function:
        return isDark ? const [Color(0xFF565660), Color(0xFF3F3F48)] : const [Color(0xFFD8DCE6), Color(0xFFBEC4D2)];
      case CalcKeyRole.memory:
        return isDark ? const [Color(0xFF4A5568), Color(0xFF374151)] : const [Color(0xFFCBD5E1), Color(0xFFA9B4C4)];
    }
  }

  Color _foregroundFor(BuildContext context) {
    switch (widget.role) {
      case CalcKeyRole.numberDark:
      case CalcKeyRole.numberLight:
      case CalcKeyRole.function:
      case CalcKeyRole.memory:
        return Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _gradientFor(context);
    final foreground = _foregroundFor(context);

    return Semantics(
      button: true,
      label: widget.semanticsLabel ?? widget.label,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            constraints: const BoxConstraints(minWidth: 64, minHeight: 64),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradient,
              ),
              boxShadow: _pressed
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.18),
                        blurRadius: 1,
                        offset: const Offset(0, -1),
                      ),
                    ],
              border: Border.all(
                color: Colors.white.withValues(alpha: _pressed ? 0.08 : 0.22),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.label,
              style: TextStyle(
                color: foreground,
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}