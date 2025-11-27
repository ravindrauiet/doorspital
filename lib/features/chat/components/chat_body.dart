import 'package:door/features/chat/components/chat_bubble_doctor.dart';
import 'package:door/features/chat/components/chat_user_bubble.dart';
import 'package:door/services/models/chat_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBody extends StatelessWidget {
  final List<ChatMessage> messages;
  final String? currentUserId;
  final ScrollController scrollController;
  final bool isLoading;
  final Future<void> Function()? onLoadMore;

  const ChatBody({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.scrollController,
    required this.isLoading,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'Say hello to start the conversation.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels <= 64 &&
            notification is ScrollUpdateNotification) {
          onLoadMore?.call();
        }
        return false;
      },
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final isMine = message.sender?.id == currentUserId;
          final timeLabel = message.createdAt != null
              ? DateFormat('hh:mm a').format(message.createdAt!.toLocal())
              : '';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Align(
              alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
              child: isMine
                  ? ChatBubbleUser(text: message.body, time: timeLabel)
                  : ChatBubbleDoctor(text: message.body, time: timeLabel),
            ),
          );
        },
      ),
    );
  }
}
