import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/widgets/typing_indicator.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isWaiting;

  const MessageBubble({
    super.key,
    required this.message,
    this.isWaiting = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: isWaiting
            ? TypingIndicator(color: scheme.onSurfaceVariant)
            : DefaultSelectionStyle(
                cursorColor: isUser ? scheme.onPrimary : scheme.primary,
                selectionColor: (isUser ? scheme.onPrimary : scheme.primary)
                    .withValues(alpha: 0.3),
                child: SelectableText(
                  message.text,
                  style: TextStyle(
                    color: isUser ? scheme.onPrimary : scheme.onSurface,
                  ),
                ),
              ),
      ),
    );
  }
}
