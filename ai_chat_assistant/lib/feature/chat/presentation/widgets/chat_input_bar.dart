import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatInputBar extends StatefulWidget {
  final bool isStreaming;
  final ValueChanged<String> onSend;
  final VoidCallback onStop;

  const ChatInputBar({
    super.key,
    required this.isStreaming,
    required this.onSend,
    required this.onStop,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isStreaming) return;
    HapticFeedback.lightImpact();
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final focused = _focusNode.hasFocus;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.fromLTRB(18, 4, 6, 4),
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.30),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: focused
                  ? scheme.primary.withValues(alpha: 0.55)
                  : scheme.outlineVariant.withValues(alpha: 0.22),
              width: 1,
            ),
            boxShadow: focused
                ? [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.10),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    minLines: 1,
                    maxLines: 5,
                    maxLength: 10000,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Ask anything',
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.65),
                      ),
                      border: InputBorder.none,
                      counterText: '',
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) {
                  final canSend = value.text.trim().isNotEmpty;
                  final active = widget.isStreaming || canSend;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? scheme.primary
                          : scheme.surfaceContainerHighest.withValues(
                              alpha: 0.35,
                            ),
                    ),
                    child: IconButton(
                      onPressed: widget.isStreaming
                          ? widget.onStop
                          : (canSend ? _submit : null),
                      color: scheme.onPrimary,
                      disabledColor: scheme.onSurfaceVariant.withValues(
                        alpha: 0.45,
                      ),
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        child: Icon(
                          widget.isStreaming
                              ? Icons.stop_rounded
                              : Icons.arrow_upward_rounded,
                          key: ValueKey(widget.isStreaming),
                        ),
                      ),
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
