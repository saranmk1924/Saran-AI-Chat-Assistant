import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';
import 'package:equatable/equatable.dart';

enum ChatStatus { initial, streaming, success, failure }

class ChatState extends Equatable {
  final List<MessageEntity> messages;
  final ChatStatus status;
  final String? errorMessage;

  const ChatState({
    this.messages = const [],
    this.status = ChatStatus.initial,
    this.errorMessage,
  });

  bool get isStreaming => status == ChatStatus.streaming;

  ChatState copyWith({
    List<MessageEntity>? messages,
    ChatStatus? status,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [messages, status, errorMessage];
}