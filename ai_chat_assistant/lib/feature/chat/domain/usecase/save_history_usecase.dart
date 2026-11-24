import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';
import 'package:ai_chat_assistant/feature/chat/domain/repository/chat_repository.dart';

class SaveHistoryUsecase {
  final ChatRepository repository;
  SaveHistoryUsecase(this.repository);

  Future<void> call(List<MessageEntity> messages) =>
      repository.saveHistory(messages);
}