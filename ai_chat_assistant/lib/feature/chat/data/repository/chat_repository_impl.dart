import 'package:ai_chat_assistant/feature/chat/data/datasource/chat_local_datasource.dart';
import 'package:ai_chat_assistant/feature/chat/data/datasource/chat_remote_datasource.dart';
import 'package:ai_chat_assistant/feature/chat/data/model/message_model.dart';
import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';
import 'package:ai_chat_assistant/feature/chat/domain/policy/context_window.dart';
import 'package:ai_chat_assistant/feature/chat/domain/repository/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource remote;
  final ChatLocalDatasource local;

  ChatRepositoryImpl(this.remote, this.local);

  @override
  Stream<String> sendMessage(List<MessageEntity> history) {
    final models =
        ContextWindow.trim(history).map(MessageModel.fromEntity).toList();
    return remote.streamMessage(models);
  }

  @override
  Future<List<MessageEntity>> loadHistory() async => local.load();

  @override
  Future<void> saveHistory(List<MessageEntity> messages) =>
      local.save(messages.map(MessageModel.fromEntity).toList());

  @override
  Future<void> clearHistory() => local.clear();
}