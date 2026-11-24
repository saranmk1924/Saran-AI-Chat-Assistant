import 'dart:async';

import 'package:ai_chat_assistant/core/utils/typewriter.dart';
import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';
import 'package:ai_chat_assistant/feature/chat/domain/failure/chat_exception.dart';
import 'package:ai_chat_assistant/feature/chat/domain/usecase/clear_history_usecase.dart';
import 'package:ai_chat_assistant/feature/chat/domain/usecase/get_history_usecase.dart';
import 'package:ai_chat_assistant/feature/chat/domain/usecase/save_history_usecase.dart';
import 'package:ai_chat_assistant/feature/chat/domain/usecase/send_message_usecase.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/bloc/chat_event.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/bloc/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUsecase sendMessageUsecase;
  final GetHistoryUsecase getHistoryUsecase;
  final SaveHistoryUsecase saveHistoryUsecase;
  final ClearHistoryUsecase clearHistoryUsecase;

  int _idCounter = 0;
  StreamSubscription<String>? _subscription;
  Completer<void>? _completer;

  ChatBloc(
    this.sendMessageUsecase,
    this.getHistoryUsecase,
    this.saveHistoryUsecase,
    this.clearHistoryUsecase,
  ) : super(const ChatState()) {
    on<LoadHistoryEvent>(_onLoadHistory);
    on<SendMessageEvent>(_onSendMessage);
    on<RetryEvent>(_onRetry);
    on<StopGenerationEvent>(_onStop);
    on<ClearHistoryEvent>(_onClear);
  }

  String _newId() => '${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

  Future<void> _persist(List<MessageEntity> messages) async {
    try {
      await saveHistoryUsecase(messages);
    } catch (_) {
      // Saving is best effort; a storage problem must not break the chat.
    }
  }

  Future<void> _onLoadHistory(
    LoadHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final messages = await getHistoryUsecase();
      if (messages.isNotEmpty && state.messages.isEmpty) {
        emit(state.copyWith(messages: messages, status: ChatStatus.success));
      }
    } catch (_) {
      // Unreadable history: start with an empty chat.
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty || state.isStreaming) return;

    final userMessage = MessageEntity(
      id: _newId(),
      role: MessageRole.user,
      text: text,
    );
    await _generate([...state.messages, userMessage], emit);
  }

  Future<void> _onRetry(RetryEvent event, Emitter<ChatState> emit) async {
    if (state.isStreaming) return;

    final messages = [...state.messages];
    if (messages.isNotEmpty && messages.last.role == MessageRole.assistant) {
      messages.removeLast();
    }
    if (messages.isEmpty || messages.last.role != MessageRole.user) return;

    await _generate(messages, emit);
  }

  void _onStop(StopGenerationEvent event, Emitter<ChatState> emit) {
    if (!state.isStreaming) return;

    unawaited(_subscription?.cancel());
    _subscription = null;

    final messages = [...state.messages];
    if (messages.isNotEmpty &&
        messages.last.role == MessageRole.assistant &&
        messages.last.text.isEmpty) {
      messages.removeLast();
    }
    emit(state.copyWith(messages: messages, status: ChatStatus.success));
    unawaited(_persist(messages));

    final completer = _completer;
    if (completer != null && !completer.isCompleted) completer.complete();
  }

  Future<void> _onClear(
    ClearHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    unawaited(_subscription?.cancel());
    _subscription = null;

    final completer = _completer;
    if (completer != null && !completer.isCompleted) completer.complete();

    emit(const ChatState());
    try {
      await clearHistoryUsecase();
    } catch (_) {}
  }

  Future<void> _generate(
    List<MessageEntity> history,
    Emitter<ChatState> emit,
  ) async {
    final placeholder = MessageEntity(
      id: _newId(),
      role: MessageRole.assistant,
      text: '',
    );
    emit(
      state.copyWith(
        messages: [...history, placeholder],
        status: ChatStatus.streaming,
      ),
    );

    final buffer = StringBuffer();
    final completer = Completer<void>();
    _completer = completer;

    _subscription = typewriter(sendMessageUsecase(history)).listen(
      (piece) {
        buffer.write(piece);
        emit(
          state.copyWith(
            messages: [
              ...history,
              placeholder.copyWith(text: buffer.toString()),
            ],
          ),
        );
      },
      onError: (Object error) {
        final failure = error is ChatException
            ? error
            : const ChatException(ChatErrorType.unknown);
        emit(
          state.copyWith(
            messages: buffer.isEmpty ? history : state.messages,
            status: ChatStatus.failure,
            errorMessage: failure.message,
            canRetry: failure.canRetry,
          ),
        );
        unawaited(_persist(state.messages));
        if (!completer.isCompleted) completer.complete();
      },
      onDone: () {
        emit(state.copyWith(status: ChatStatus.success));
        unawaited(_persist(state.messages));
        if (!completer.isCompleted) completer.complete();
      },
      cancelOnError: true,
    );

    await completer.future;
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}