import 'package:flutter/material.dart';
import 'package:flutter_wubbachat/chat_repository/chat_repository.dart';

class MessageView extends StatelessWidget {
  MessageView({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return ListTile(subtitle: Text(message.body));
  }
}
