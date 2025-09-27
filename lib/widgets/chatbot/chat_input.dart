// chat_input.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skinsage/controllers/chatController.dart';

class ChatInput extends StatelessWidget {
  ChatInput({super.key});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatController = Get.find<ChatController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (text) {
                chatController.sendMessage(text);
                _controller.clear();
              },
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.purple),
            onPressed: () {
              chatController.sendMessage(_controller.text);
              _controller.clear();
            },
          )
        ],
      ),
    );
  }
}
