import 'dart:async';

import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';
import 'package:ai_chat_assistant/feature/chat/domain/failure/chat_exception.dart';
import 'package:ai_chat_assistant/feature/chat/domain/usecase/clear_history_usecase.dart';
import 'package:ai_chat_assistant/feature/chat/domain/usecase/get_history_usecase.dart';
import 'package:ai_chat_assistant/feature/chat/domain/usecase/save_history_usecase.dart';
import 'package:ai_chat_assistant/feature/chat/domain/usecase/send_message_usecase.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/bloc/chat_bloc.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/bloc/chat_event.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/bloc/chat_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_chat_repository.dart';

void main() {
  late FakeChatRepository repo;
  late ChatBloc bloc;

  setUp(() {
    repo = FakeChatRepository();
    bloc = ChatBloc(
      SendMessageUsecase(repo),
      GetHistoryUsecase(repo),
      SaveHistoryUsecase(repo),
      ClearHistoryUsecase(repo),
    );
  });

  tearDown(() => bloc.close());

  Future<ChatState> waitForStatus(ChatStatus status) =>
      bloc.stream.firstWhere((s) => s.status == status);

  group('sending a message', () {
    test('streams the answer, sends no empty message, and saves history',
        () async {
      repo.onSend = (_) => Stream.fromIterable(['Hel', 'lo']);

      bloc.add(const SendMessageEvent('hi'));
      final state = await waitForStatus(ChatStatus.success);

      expect(state.messages.map((m) => m.role), [
        MessageRole.user,
        MessageRole.assistant,
      ]);
      expect(state.messages.last.text, 'Hello');

      // the request must contain only the user message, never the empty placeholder
      expect(repo.sentHistories.single.length, 1);
      expect(repo.sentHistories.single.single.text, 'hi');

      expect(repo.lastSaved?.length, 2);
      expect(repo.lastSaved?.last.text, 'Hello');
    });

    test('ignores empty or whitespace-only input', () async {
      bloc.add(const SendMessageEvent('   '));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.messages, isEmpty);
      expect(repo.sentHistories, isEmpty);
    });
  });

  group('errors', () {
    test('a rate limit keeps the question and allows retry', () async {
      repo.onSend =
          (_) => Stream.error(const ChatException(ChatErrorType.rateLimit));

      bloc.add(const SendMessageEvent('hi'));
      final state = await waitForStatus(ChatStatus.failure);

      expect(state.messages.length, 1);
      expect(state.messages.single.role, MessageRole.user);
      expect(
        state.errorMessage,
        const ChatException(ChatErrorType.rateLimit).message,
      );
      expect(state.canRetry, isTrue);
    });

    test('a rejected key does not allow retry', () async {
      repo.onSend =
          (_) => Stream.error(const ChatException(ChatErrorType.invalidKey));

      bloc.add(const SendMessageEvent('hi'));
      final state = await waitForStatus(ChatStatus.failure);

      expect(state.canRetry, isFalse);
    });

    test('retry resends the same question without duplicating it', () async {
      var calls = 0;
      repo.onSend = (_) {
        calls++;
        return calls == 1
            ? Stream.error(const ChatException(ChatErrorType.overloaded))
            : Stream.fromIterable(['OK']);
      };

      bloc.add(const SendMessageEvent('hi'));
      await waitForStatus(ChatStatus.failure);

      bloc.add(const RetryEvent());
      final state = await waitForStatus(ChatStatus.success);

      expect(state.messages.length, 2);
      expect(state.messages.last.text, 'OK');
      expect(repo.sentHistories.length, 2);
      expect(repo.sentHistories.last.length, 1);
    });
  });

  group('stop generation', () {
    test('keeps the text received so far and stops streaming', () async {
      final controller = StreamController<String>();
      addTearDown(controller.close);
      repo.onSend = (_) => controller.stream;

      bloc.add(const SendMessageEvent('hi'));
      controller.add('Hi');
      await bloc.stream.firstWhere(
        (s) => s.messages.isNotEmpty && s.messages.last.text.isNotEmpty,
      );

      bloc.add(const StopGenerationEvent());
      final state = await waitForStatus(ChatStatus.success);

      expect(state.isStreaming, isFalse);
      expect(state.messages.last.text, 'Hi');
      expect(repo.lastSaved, isNotNull);
    });
  });

  group('history', () {
    test('loads saved messages and can clear them', () async {
      repo.storedHistory = const [
        MessageEntity(id: '1', role: MessageRole.user, text: 'hi'),
        MessageEntity(id: '2', role: MessageRole.assistant, text: 'hello'),
      ];

      bloc.add(const LoadHistoryEvent());
      final loaded = await bloc.stream.first;
      expect(loaded.messages.length, 2);

      bloc.add(const ClearHistoryEvent());
      final cleared = await bloc.stream.first;
      expect(cleared.messages, isEmpty);
      expect(repo.clearCalls, 1);
    });
  });
}