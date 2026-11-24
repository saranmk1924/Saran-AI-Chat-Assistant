import 'package:ai_chat_assistant/feature/chat/domain/repository/chat_repository.dart';

class ClearHistoryUsecase {
  final ChatRepository repository;
  ClearHistoryUsecase(this.repository);

  Future<void> call() => repository.clearHistory();
}