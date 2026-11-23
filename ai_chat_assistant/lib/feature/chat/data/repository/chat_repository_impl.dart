import 'package:ai_chat_assistant/feature/chat/data/datasource/chat_remote_datasource.dart';
import 'package:ai_chat_assistant/feature/chat/data/model/message_model.dart';
import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';
import 'package:ai_chat_assistant/feature/chat/domain/repository/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource datasource;

  ChatRepositoryImpl(this.datasource);

  @override
  Stream<String> sendMessage(List<MessageEntity> history) {
    final models = history.map(MessageModel.fromEntity).toList();
    return datasource.streamMessage(models);
  }
}