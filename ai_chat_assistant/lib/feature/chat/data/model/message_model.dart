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

  Map<String, dynamic> toProxyJson() => {'role': role.name, 'text': text};

  Map<String, dynamic> toJson() => {'id': id, 'role': role.name, 'text': text};

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      role: MessageRole.values.byName(json['role'] as String),
      text: json['text'] as String,
    );
  }
}
