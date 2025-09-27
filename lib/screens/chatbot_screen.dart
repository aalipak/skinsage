// chatbot_screen.dart
import 'package:flutter/material.dart';
import 'package:skinsage/widgets/chatbot/chat_input.dart';
import 'package:skinsage/widgets/chatbot/message_list.dart';


class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Chatbot")),
      body: Column(
        children: [
          Expanded(child: MessageList()),
          ChatInput(),
        ],
      ),
    );
  }
}
