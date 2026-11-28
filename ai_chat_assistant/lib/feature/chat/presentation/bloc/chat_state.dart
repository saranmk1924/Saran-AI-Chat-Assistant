import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';
import 'package:ai_chat_assistant/feature/chat/domain/policy/context_window.dart';
import 'package:equatable/equatable.dart';

enum ChatStatus { initial, streaming, success, failure }

class ChatState extends Equatable {
  final List<MessageEntity> messages;
  final ChatStatus status;
  final String? errorMessage;
  final bool canRetry;

  const ChatState({
    this.messages = const [],
    this.status = ChatStatus.initial,
    this.errorMessage,
    this.canRetry = false,
  });

  bool get isStreaming => status == ChatStatus.streaming;

  /// True when the AI no longer reads the whole chat (shows the notice).
  bool get isContextTrimmed => ContextWindow.isTrimmed(messages);

  ChatState copyWith({
    List<MessageEntity>? messages,
    ChatStatus? status,
    String? errorMessage,
    bool canRetry = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      errorMessage: errorMessage,
      canRetry: canRetry,
    );
  }

  @override
  List<Object?> get props => [messages, status, errorMessage, canRetry];
}
