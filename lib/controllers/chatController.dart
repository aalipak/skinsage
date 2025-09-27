import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  // Safely access API key with null checking
  String? get togetherApiKey => dotenv.env['TOGETHER_API_KEY'];

  var messages = <Map<String, String>>[].obs;
  var isLoading = false.obs; // Track loading state globally

  @override
  void onInit() {
    super.onInit();
    // Print API key length to verify it's loaded (don't print the actual key for security)
    if (togetherApiKey == null) {
      print('ERROR: TOGETHER_API_KEY not found in .env file');
    } else {
      print(
          'API key loaded successfully (${togetherApiKey!.length} characters)');
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (isLoading.value) {
      print('Already processing a request, ignoring new message');
      return; // Prevent multiple simultaneous requests
    }

    // Add user message
    messages.add({'sender': 'user', 'text': text});
    // Add loading message
    final loadingIndex = messages.length;
    messages.add({'sender': 'bot', 'text': 'Loading...'});
    isLoading.value = true;

    // Simple loading animation
    var dots = 0;
    Timer? animationTimer =
        Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (!isLoading.value) {
        timer.cancel();
        return;
      }

      dots = (dots + 1) % 4;
      messages[loadingIndex] = {
        'sender': 'bot',
        'text': 'Loading' + ('.' * dots)
      };
    });

    try {
      // Check if API key exists
      if (togetherApiKey == null) {
        throw Exception('TOGETHER_API_KEY not found in environment variables');
      }

      print('Making API request to Together AI...');
      final response = await http.post(
        Uri.parse('https://api.together.xyz/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $togetherApiKey',
        },
        body: jsonEncode({
          'model': 'meta-llama/Llama-4-Maverick-17B-128E-Instruct-FP8',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are Maverick - an advanced AI assistant. Respond concisely (2-3 sentences max).'
            },
            {'role': 'user', 'content': text},
          ],
          'temperature': 0.4,
          'top_p': 0.9,
          'max_tokens': 256,
          'stop': ['</s>', '###'],
        }),
      );

      print('Response received: Status ${response.statusCode}');

      // Remove loading message and cancel animation
      animationTimer?.cancel();
      messages.removeAt(loadingIndex);
      isLoading.value = false;

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('Response parsed successfully');
          final content = data['choices'][0]['message']['content'];
          messages.add({
            'sender': 'bot',
            'text': content.trim().replaceAll(RegExp(r'\n+'), '\n\n')
          });
        } catch (parseError) {
          print('Error parsing response: $parseError');
          print('Response body: ${response.body}');
          messages.add({
            'sender': 'bot',
            'text': '⚠️ Error parsing response. Check logs for details.'
          });
        }
      } else {
        print('API Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        messages.add({
          'sender': 'bot',
          'text':
              '⚠️ API Error: ${response.statusCode}\n${response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body}'
        });
      }
    } catch (e) {
      print('Exception occurred: $e');

      // Ensure animation is cancelled and loading state is reset
      animationTimer?.cancel();
      if (loadingIndex < messages.length) {
        messages.removeAt(loadingIndex);
      }
      isLoading.value = false;

      messages.add(
          {'sender': 'bot', 'text': '🚨 Connection Failed\n${e.toString()}'});
    }
  }
}
