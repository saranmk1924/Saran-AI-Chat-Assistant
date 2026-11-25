import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';
import 'package:ai_chat_assistant/feature/chat/domain/usecase/send_message_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_chat_repository.dart';

void main() {
  test('passes the history to the repository and returns its stream', () async {
    final repo = FakeChatRepository()
      ..onSend = (_) => Stream.fromIterable(['Hel', 'lo']);
    final usecase = SendMessageUsecase(repo);
    const history = [
      MessageEntity(id: '1', role: MessageRole.user, text: 'hi'),
    ];

    final pieces = await usecase(history).toList();

    expect(pieces, ['Hel', 'lo']);
    expect(repo.sentHistories.single, history);
  });
}