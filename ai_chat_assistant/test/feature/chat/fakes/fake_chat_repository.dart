import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';
import 'package:ai_chat_assistant/feature/chat/domain/repository/chat_repository.dart';

class FakeChatRepository implements ChatRepository {
  Stream<String> Function(List<MessageEntity> history) onSend =
      (_) => const Stream<String>.empty();

  List<MessageEntity> storedHistory = [];

  final List<List<MessageEntity>> sentHistories = [];
  List<MessageEntity>? lastSaved;
  int clearCalls = 0;

  @override
  Stream<String> sendMessage(List<MessageEntity> history) {
    sentHistories.add(List.of(history));
    return onSend(history);
  }

  @override
  Future<List<MessageEntity>> loadHistory() async => storedHistory;

  @override
  Future<void> saveHistory(List<MessageEntity> messages) async {
    lastSaved = List.of(messages);
  }

  @override
  Future<void> clearHistory() async {
    clearCalls++;
  }
}