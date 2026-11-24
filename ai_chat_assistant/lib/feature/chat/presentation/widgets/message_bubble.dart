import 'package:ai_chat_assistant/core/common_widget/gradient_sparkle.dart';
import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/widgets/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isWaiting;
  final bool showActions;

  const MessageBubble({
    super.key,
    required this.message,
    this.isWaiting = false,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: child),
      ),
      child: isUser
          ? _UserMessage(text: message.text)
          : _AssistantMessage(
              text: message.text,
              isWaiting: isWaiting,
              showActions: showActions,
            ),
    );
  }
}

class _UserMessage extends StatelessWidget {
  final String text;

  const _UserMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(6),
          ),
        ),
        child: SelectableText(
          text,
          style: TextStyle(
            color: scheme.onPrimaryContainer,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _AssistantMessage extends StatelessWidget {
  final String text;
  final bool isWaiting;
  final bool showActions;

  const _AssistantMessage({
    required this.text,
    required this.isWaiting,
    required this.showActions,
  });

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, 0, 16, 96),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: GradientSparkle(size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isWaiting)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TypingIndicator(color: scheme.onSurfaceVariant),
                  )
                else
                  SelectableText(
                    text,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 16,
                      height: 1.55,
                    ),
                  ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.topLeft,
                  child: showActions
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: IconButton(
                            tooltip: 'Copy',
                            visualDensity: VisualDensity.compact,
                            iconSize: 18,
                            color: scheme.onSurfaceVariant,
                            icon: const Icon(Icons.content_copy_outlined),
                            onPressed: () => _copy(context),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}