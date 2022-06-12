import 'package:flutter/material.dart';
import 'package:flutter_wubbachat/pages/chat/view/chat_view.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return ChatView(id: id);
  }
}
