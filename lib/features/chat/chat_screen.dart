import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/notifiers.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.state});

  static const route = '/chat';

  final AppState state;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ValueNotifier<List<_ChatMessage>> _messages = ValueNotifier([]);
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _botTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = AppLocalizations.of(context);
      _messages.value = [
        _ChatMessage(
          text: loc.translate('chat_intro'),
          fromUser: false,
          timestamp: DateTime.now(),
        ),
      ];
    });
  }

  @override
  void dispose() {
    _botTimer?.cancel();
    _messages.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final now = DateTime.now();
    final updated = [..._messages.value, _ChatMessage(text: text, fromUser: true, timestamp: now)];
    _messages.value = updated;
    _controller.clear();
    _scrollToEnd();
    _scheduleBotReply();
  }

  void _scheduleBotReply() {
    _botTimer?.cancel();
    _botTimer = Timer(const Duration(milliseconds: 700), () {
      final loc = AppLocalizations.of(context);
      final reply = _ChatMessage(
        text: loc.translate('chat_bot_reply'),
        fromUser: false,
        timestamp: DateTime.now(),
      );
      _messages.value = [..._messages.value, reply];
      _scrollToEnd();
    });
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 72,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('chat_title')),
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<List<_ChatMessage>>(
              valueListenable: _messages,
              builder: (context, messages, _) {
                if (messages.isEmpty) {
                  return const SizedBox.shrink();
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final alignment = message.fromUser ? Alignment.centerRight : Alignment.centerLeft;
                    final bubbleColor = message.fromUser
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface.withOpacity(theme.brightness == Brightness.dark ? 0.7 : 1);
                    final textColor = message.fromUser ? Colors.white : theme.colorScheme.onSurface;
                    return Align(
                      alignment: alignment,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 8,
                          bottom: 8,
                          left: message.fromUser ? 48 : 0,
                          right: message.fromUser ? 0 : 48,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: bubbleColor,
                            borderRadius: BorderRadius.circular(24).copyWith(
                              bottomLeft: message.fromUser ? const Radius.circular(24) : Radius.zero,
                              bottomRight: message.fromUser ? Radius.zero : const Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(message.fromUser ? 0.2 : 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment:
                                message.fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(message.text, style: theme.textTheme.bodyMedium?.copyWith(color: textColor)),
                              const SizedBox(height: 6),
                              Text(
                                _formatTime(message.timestamp),
                                style: theme.textTheme.labelSmall?.copyWith(color: textColor.withOpacity(0.7)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: loc.translate('chat_hint'),
                      filled: true,
                      suffixIcon: IconButton(
                        icon: const Icon(IconlyLight.voice),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _sendMessage,
                  icon: const Icon(IconlyLight.send),
                  label: Text(loc.translate('send')),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.fromUser, required this.timestamp});

  final String text;
  final bool fromUser;
  final DateTime timestamp;
}
