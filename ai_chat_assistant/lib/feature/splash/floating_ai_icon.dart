import 'package:flutter/material.dart';

class FloatingAIIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Duration duration;
  final double size;

  const FloatingAIIcon({
    super.key,
    required this.icon,
    required this.color,
    this.duration = const Duration(milliseconds: 1800),
    this.size = 21,
  });

  @override
  State<FloatingAIIcon> createState() => _FloatingAIIconState();
}

class _FloatingAIIconState extends State<FloatingAIIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -5,
      end: 5,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: const Color(0xFF201B3A),
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.color.withValues(alpha: 0.5),
          ),
        ),
        child: Icon(
          widget.icon,
          color: widget.color,
          size: widget.size,
        ),
      ),
    );
  }
}