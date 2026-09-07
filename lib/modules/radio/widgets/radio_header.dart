/// FILE: lib/modules/radio/widgets/radio_header.dart
import 'package:flutter/material.dart';

class RadioHeader extends StatefulWidget {
  const RadioHeader({super.key});

  @override
  State<RadioHeader> createState() => _RadioHeaderState();
}

class _RadioHeaderState extends State<RadioHeader> with SingleTickerProviderStateMixin {
  late final AnimationController _waveController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_waveController.value * 0.1),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF00E5FF), const Color(0xFF3B82F6)]
                          : [const Color(0xFF0284C7), const Color(0xFF2563EB)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? const Color(0xFF00E5FF) : const Color(0xFF0284C7))
                            .withOpacity(0.4 * _waveController.value),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.radio_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🎵 OmniToolkit Radio',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Worldwide Internet Radio',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
