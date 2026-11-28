import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';

/// Decides how much of the conversation the AI gets to read.
/// Must stay BELOW the Worker's limits (60 messages / 50,000 chars),
/// otherwise the Worker answers 400.
class ContextWindow {
  ContextWindow._();

  static const maxMessages = 40;
  static const maxChars = 40000;

  /// Keeps only the most recent part of the conversation that fits the limits.
  /// The newest message is always kept.
  static List<MessageEntity> trim(List<MessageEntity> history) {
    final kept = <MessageEntity>[];
    var chars = 0;

    for (final message in history.reversed) {
      final isNewest = kept.isEmpty;
      final tooMany = kept.length >= maxMessages;
      final tooLong = chars + message.text.length > maxChars;
      if (!isNewest && (tooMany || tooLong)) break;

      kept.add(message);
      chars += message.text.length;
    }

    final result = kept.reversed.toList();
    while (result.length > 1 && result.first.role != MessageRole.user) {
      result.removeAt(0);
    }
    return result;
  }

  /// True when the next request would not include the whole chat.
  /// Empty messages (the waiting placeholder) are ignored, because
  /// they are never sent to the API.
  static bool isTrimmed(List<MessageEntity> messages) {
    final real = messages.where((m) => m.text.isNotEmpty).toList();
    return trim(real).length < real.length;
  }
}
