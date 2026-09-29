import 'package:get/get.dart';

class ChatMessage {
  final String text;
  final bool isMe;
  ChatMessage(this.text, this.isMe);
}

class ChatController extends GetxController {
  var messages = <ChatMessage>[].obs;

  void sendMessage(String text) {
    if (text.isEmpty) return;
    messages.add(ChatMessage(text, true));
    // Simulate reply
    Future.delayed(const Duration(seconds: 1), () {
      messages.add(ChatMessage('Got your message!', false));
    });
  }
}
