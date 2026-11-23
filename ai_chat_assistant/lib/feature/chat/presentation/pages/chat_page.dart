import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/bloc/chat_bloc.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/bloc/chat_event.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/bloc/chat_state.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/widgets/chat_input_bar.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Chat Assistant')),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ChatBloc, ChatState>(
            listenWhen: (prev, curr) => prev.messages != curr.messages,
            listener: (context, state) => _scrollToBottom(),
          ),
          BlocListener<ChatBloc, ChatState>(
            listenWhen: (prev, curr) =>
                prev.status != curr.status && curr.status == ChatStatus.failure,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Error')),
              );
            },
          ),
        ],
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state.messages.isEmpty) {
                    return const Center(child: Text('Ask me anything'));
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isLast = index == state.messages.length - 1;
                      final isWaiting = isLast &&
                          state.isStreaming &&
                          message.role == MessageRole.assistant &&
                          message.text.isEmpty;
                      return MessageBubble(
                        message: message,
                        isWaiting: isWaiting,
                      );
                    },
                  );
                },
              ),
            ),
            BlocBuilder<ChatBloc, ChatState>(
              buildWhen: (prev, curr) => prev.isStreaming != curr.isStreaming,
              builder: (context, state) {
                return ChatInputBar(
                  enabled: !state.isStreaming,
                  onSend: (text) =>
                      context.read<ChatBloc>().add(SendMessageEvent(text)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}