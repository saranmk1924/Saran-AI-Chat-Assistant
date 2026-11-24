import 'package:ai_chat_assistant/core/common_widget/chat_background.dart';
import 'package:ai_chat_assistant/feature/chat/domain/entity/message_entity.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/bloc/chat_bloc.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/bloc/chat_event.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/bloc/chat_state.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/widgets/chat_input_bar.dart';
import 'package:ai_chat_assistant/feature/chat/presentation/widgets/empty_chat_view.dart';
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
  final _showJumpButton = ValueNotifier<bool>(false);
  bool _stickToBottom = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final p = _scrollController.position;
      _stickToBottom = p.pixels >= p.maxScrollExtent - 80;
      _showJumpButton.value = !_stickToBottom;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _showJumpButton.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_stickToBottom || !_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _jumpToBottom() {
    if (!_scrollController.hasClients) return;
    _stickToBottom = true;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _send(BuildContext context, String text) {
    _stickToBottom = true;
    context.read<ChatBloc>().add(SendMessageEvent(text));
  }

  Future<void> _confirmClear(BuildContext context) async {
    final bloc = context.read<ChatBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear chat?'),
        content: const Text('This deletes the whole conversation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) bloc.add(const ClearHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          titleSpacing: 20,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    width: 1.2,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage('assets/app_icon.png'),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Saran AI',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            BlocBuilder<ChatBloc, ChatState>(
              buildWhen: (prev, curr) =>
                  prev.messages.isEmpty != curr.messages.isEmpty,
              builder: (context, state) {
                return IconButton(
                  tooltip: 'Clear chat',
                  icon: const Icon(Icons.delete_outline_rounded, size: 22),
                  color: theme.colorScheme.onSurfaceVariant,
                  disabledColor: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.30,
                  ),
                  onPressed: state.messages.isEmpty
                      ? null
                      : () => _confirmClear(context),
                );
              },
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<ChatBloc, ChatState>(
              listenWhen: (prev, curr) => prev.messages != curr.messages,
              listener: (context, state) => _scrollToBottom(),
            ),
            BlocListener<ChatBloc, ChatState>(
              listenWhen: (prev, curr) =>
                  prev.status != curr.status &&
                  curr.status == ChatStatus.failure,
              listener: (context, state) {
                final messenger = ScaffoldMessenger.of(context);
                messenger.hideCurrentSnackBar();
                messenger.showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    content: Text(
                      state.errorMessage ?? 'Something went wrong.',
                    ),
                    duration: const Duration(seconds: 6),
                    action: state.canRetry
                        ? SnackBarAction(
                            label: 'Retry',
                            onPressed: () => context.read<ChatBloc>().add(
                              const RetryEvent(),
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ],
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state) {
                        if (state.messages.isEmpty) {
                          return EmptyChatView(
                            onSuggestion: (text) => _send(context, text),
                          );
                        }
                        return ListView.builder(
                          controller: _scrollController,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            final isLast = index == state.messages.length - 1;
                            final isAssistant =
                                message.role == MessageRole.assistant;
                            final streamingThis = isLast && state.isStreaming;

                            return MessageBubble(
                              key: ValueKey(message.id),
                              message: message,
                              isWaiting:
                                  streamingThis &&
                                  isAssistant &&
                                  message.text.isEmpty,
                              showActions:
                                  isAssistant &&
                                  message.text.isNotEmpty &&
                                  !streamingThis,
                            );
                          },
                        );
                      },
                    ),
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _showJumpButton,
                          builder: (context, show, _) {
                            return IgnorePointer(
                              ignoring: !show,
                              child: AnimatedScale(
                                scale: show ? 1 : 0,
                                duration: const Duration(milliseconds: 150),
                                child: IconButton.filledTonal(
                                  tooltip: 'Scroll to latest',
                                  onPressed: _jumpToBottom,
                                  icon: const Icon(
                                    Icons.arrow_downward_rounded,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              BlocBuilder<ChatBloc, ChatState>(
                buildWhen: (prev, curr) => prev.isStreaming != curr.isStreaming,
                builder: (context, state) {
                  return ChatInputBar(
                    isStreaming: state.isStreaming,
                    onSend: (text) => _send(context, text),
                    onStop: () => context.read<ChatBloc>().add(
                      const StopGenerationEvent(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
