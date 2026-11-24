import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';
import 'package:ai_chat_assistant/feature/chat/domain/repository/chat_repository.dart';

class GetHistoryUsecase {
  final ChatRepository repository;
  GetHistoryUsecase(this.repository);

  Future<List<MessageEntity>> call() => repository.loadHistory();
}