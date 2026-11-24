import 'package:ai_chat_assistant/core/common_widget/gradient_sparkle.dart';
import 'package:flutter/material.dart';

class EmptyChatView extends StatelessWidget {
  final ValueChanged<String> onSuggestion;

  const EmptyChatView({super.key, required this.onSuggestion});

  static const _suggestions = <_Suggestion>[
    _Suggestion(Icons.lightbulb_outline, 'Explain BLoC and Cubit in simple words'),
    _Suggestion(Icons.compare_arrows, 'Compare REST and GraphQL'),
    _Suggestion(
      Icons.rocket_launch_outlined,
      'Suggest a Flutter project idea for my portfolio',
    ),
  ];

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final headline = theme.textTheme.headlineLarge?.copyWith(
      fontWeight: FontWeight.w300,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(opacity: t, child: child),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const GradientSparkle(size: 40),
                    const SizedBox(height: 20),
                    Text(_greeting(), style: headline),
                    Text(
                      'What can I help with?',
                      textAlign: TextAlign.center,
                      style: headline?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Column(
              children: [
                for (final s in _suggestions)
                  _SuggestionRow(
                    suggestion: s,
                    onTap: () => onSuggestion(s.text),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Suggestion {
  final IconData icon;
  final String text;

  const _Suggestion(this.icon, this.text);
}

class _SuggestionRow extends StatelessWidget {
  final _Suggestion suggestion;
  final VoidCallback onTap;

  const _SuggestionRow({required this.suggestion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                suggestion.icon,
                size: 22,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(suggestion.text, style: theme.textTheme.bodyLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}