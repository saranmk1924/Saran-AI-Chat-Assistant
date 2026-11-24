import 'package:flutter/material.dart';

class GradientSparkle extends StatelessWidget {
  final double size;

  const GradientSparkle({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF6C8CFF), Color(0xFFB07CFF), Color(0xFFFF8FB1)],
      ).createShader(bounds),
      child: Icon(Icons.auto_awesome, size: size, color: Colors.white),
    );
  }
}