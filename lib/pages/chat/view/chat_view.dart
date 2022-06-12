import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wubbachat/chat_repository/chat_repository.dart';
import 'package:flutter_wubbachat/l10n/l10n.dart';
import 'package:flutter_wubbachat/pages/chat/view/message_view.dart';
import 'package:flutter_wubbachat/pages/pages.dart';
import 'package:go_router/go_router.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    void _onSharePressed() {
      context.goNamed(
        ChatPageName.sharechat.name,
        params: {'page': HomePageName.chats.name, 'id': id},
      );
    }

    return ValueListenableBuilder(
      valueListenable:
          context.read<ChatRepository>().getChatListenamble(id: id),
      builder: (context, _, __) {
        final chat = context.read<ChatRepository>().getChat(id: id);
        final messages = context.read<ChatRepository>().getChatMessages(id: id);
        return Scaffold(
          appBar: AppBar(
            title: Text(chat.name),
            actions: [
              IconButton(
                onPressed: _onSharePressed,
                icon: const Icon(Icons.share),
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (BuildContext context, int index) {
              final message = messages[index];
              return MessageView(message: message);
            },
          ),
        );
      },
    );
  }
}
