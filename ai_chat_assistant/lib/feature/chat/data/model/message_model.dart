import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.role,
    required super.text,
  });

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(id: entity.id, role: entity.role, text: entity.text);
  }

  Map<String, dynamic> toGeminiJson() {
    return {
      'role': role == MessageRole.user ? 'user' : 'model',
      'parts': [
        {'text': text},
      ],
    };
  }
}