import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';

abstract class ChatRepository {
  Stream<String> sendMessage(List<MessageEntity> history);
}