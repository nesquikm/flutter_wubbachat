import 'package:flutter/material.dart';
import 'package:flutter_wubbachat/chat_repository/chat_repository.dart';

class ChatView extends StatelessWidget {
  ChatView({super.key, required this.chat, this.onTap}) {
    final exp = RegExp(r'(.*)\s*\.\s*(.*)');
    final match = exp.firstMatch(chat.name);

    if (match != null) {
      _title = match[1]!;
      _subtitle = match[2]!;
    } else {
      _title = chat.name;
      _subtitle = '';
    }
  }

  final Chat chat;
  late final String _title;
  late final String _subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_title),
      subtitle: Text(_subtitle),
      onTap: onTap,
    );
  }
}
