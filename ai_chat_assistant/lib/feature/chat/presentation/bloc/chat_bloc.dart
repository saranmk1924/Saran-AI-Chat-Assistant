import 'package:ai_chat_assistant/core/utils/typewriter.dart';
import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';
import 'package:ai_chat_assistant/feature/chat/domain/usecase/send_message_usecase.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/bloc/chat_event.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/bloc/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUsecase sendMessageUsecase;
  int _idCounter = 0;

  ChatBloc(this.sendMessageUsecase) : super(const ChatState()) {
    on<SendMessageEvent>(_onSendMessage);
  }

  String _newId() => '${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

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
    final history = [...state.messages, userMessage];
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
    try {
      await for (final piece in typewriter(sendMessageUsecase(history))) {
        buffer.write(piece);
        emit(
          state.copyWith(
            messages: [...history, placeholder.copyWith(text: buffer.toString())],
          ),
        );
      }
      emit(state.copyWith(status: ChatStatus.success));
    } catch (_) {
      emit(
        state.copyWith(
          messages: buffer.isEmpty ? history : state.messages,
          status: ChatStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }
}