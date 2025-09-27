// message_list.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skinsage/controllers/chatController.dart';

class MessageList extends StatelessWidget {
  const MessageList({super.key});

  @override
  Widget build(BuildContext context) {
    final chatController = Get.find<ChatController>();

    return Obx(() => ListView.builder(
          padding: const EdgeInsets.all(12),
          reverse: true,
          itemCount: chatController.messages.length,
          itemBuilder: (context, index) {
            final reversedIndex = chatController.messages.length - 1 - index;
            final message = chatController.messages[reversedIndex];
            final isUser = message['sender'] == 'user';

            return Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7),
                decoration: BoxDecoration(
                  color: isUser ? Colors.purple[200] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message['text'] ?? '',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          },
        ));
  }
}
