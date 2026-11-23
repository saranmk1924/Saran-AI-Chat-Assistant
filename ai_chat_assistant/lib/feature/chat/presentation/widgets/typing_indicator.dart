import 'dart:math' as math;

import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  final Color? color;

  const TypingIndicator({super.key, this.color});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  final color = widget.color ?? Theme.of(context).colorScheme.primary;
  const dotSize = 5.0;
  const bounce = 4.0;

  return SizedBox(
    height: dotSize + bounce,
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(3, (i) {
            final t = (_controller.value - i * 0.15) % 1.0;
            final wave = (math.sin(t * 2 * math.pi) + 1) / 2;

            return Transform.translate(
              offset: Offset(0, -bounce * wave),
              child: Opacity(
                opacity: 0.35 + 0.65 * wave,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    ),
  );
}
}