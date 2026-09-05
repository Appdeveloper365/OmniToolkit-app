/// FILE: lib/modules/radio/widgets/audio_visualizer_widget.dart
import 'package:flutter/material.dart';

import '../providers/radio_provider.dart';

class AudioVisualizerWidget extends StatefulWidget {
  const AudioVisualizerWidget({
    super.key,
    required this.status,
    this.barCount = 7,
    this.height = 36.0,
  });

  final RadioStatus status;
  final int barCount;
  final double height;

  @override
  State<AudioVisualizerWidget> createState() => _AudioVisualizerWidgetState();
}

class _AudioVisualizerWidgetState extends State<AudioVisualizerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    _updateAnimationState();
  }

  @override
  void didUpdateWidget(covariant AudioVisualizerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _updateAnimationState();
    }
  }

  void _updateAnimationState() {
    if (widget.status == RadioStatus.live) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else if (widget.status == RadioStatus.buffering || widget.status == RadioStatus.reconnecting) {
      _controller.stop();
    } else {
      _controller.stop();
      _controller.value = 0.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeColor = isDark ? const Color(0xFF00E5FF) : const Color(0xFF0284C7);
    final inactiveColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: widget.height,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.barCount, (index) {
              final phaseShift = (index * 0.2) % 1.0;
              final val = (widget.status == RadioStatus.live)
                  ? (0.2 + 0.8 * ((_controller.value + phaseShift) % 1.0))
                  : (widget.status == RadioStatus.buffering || widget.status == RadioStatus.reconnecting)
                      ? 0.4
                      : 0.15;

              final barHeight = widget.height * val;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 4,
                height: barHeight,
                decoration: BoxDecoration(
                  color: (widget.status == RadioStatus.live) ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: (widget.status == RadioStatus.live)
                      ? [
                          BoxShadow(
                            color: activeColor.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
