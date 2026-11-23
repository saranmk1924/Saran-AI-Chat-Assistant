import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';
import 'package:ai_chat_assistant/feature/chat/domain/repository/chat_repository.dart';

class SendMessageUsecase {
  final ChatRepository repository;

  SendMessageUsecase(this.repository);

  Stream<String> call(List<MessageEntity> history) {
    return repository.sendMessage(history);
  }
}