import 'package:flutter/material.dart';

class ChatBackground extends StatelessWidget {
  final Widget child;

  const ChatBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (theme.brightness == Brightness.light) {
      return ColoredBox(color: theme.colorScheme.surface, child: child);
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.55, 1.0],
          colors: [Color(0xFF05060F), Color(0xFF070A1E), Color(0xFF121C5A)],
        ),
      ),
      child: child,
    );
  }
}