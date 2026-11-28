import 'package:ai_chat_assistant/feature/chat/domain/policy/context_window.dart';
import 'package:flutter/material.dart';

/// Small right-aligned hint shown above the input bar when the chat is
/// longer than what the AI reads. Slides in and out smoothly.
class ContextNotice extends StatelessWidget {
  final bool visible;

  const ContextNotice({super.key, required this.visible});

  // 15000 -> "15,000"
  static String _withCommas(int number) => number.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );

  static String get message =>
      'This chat is getting long, so the AI will reply using only the most '
      'recent part of it: the last ${ContextWindow.maxMessages} messages or '
      '${_withCommas(ContextWindow.maxChars)} characters, whichever limit '
      'is reached first. Older messages stay visible but are not read.';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.bottomCenter,
      child: visible
          ? Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 2),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  message,
                  textAlign: TextAlign.left,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox(width: double.infinity),
    );
  }
}
