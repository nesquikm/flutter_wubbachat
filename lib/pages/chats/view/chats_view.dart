import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wubbachat/chat_repository/chat_repository.dart';
import 'package:flutter_wubbachat/l10n/l10n.dart';
import 'package:flutter_wubbachat/pages/chats/view/add_chat_dialog.dart';
import 'package:flutter_wubbachat/pages/chats/view/chat_view.dart';
import 'package:flutter_wubbachat/pages/pages.dart';
import 'package:go_router/go_router.dart';

class ChatsView extends StatefulWidget {
  const ChatsView({super.key});

  @override
  State<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<ChatsView> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    Future<void> _onAddPressed() async {
      final result = await showAddChatDialog(context);

      if (!mounted || result == null) return;
      if (result == '') {
        await context.read<ChatRepository>().createRandomChat();
        return;
      }

      try {
        await context.read<ChatRepository>().createChatFromTopic(topic: result);
      } catch (error) {
        log('handleRemoteMessage: $error');

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorJoinChat),
          ),
        );
      }
    }

    void _onDismissed(Chat chat) {
      context.read<ChatRepository>().deleteChat(id: chat.id);

      void _onUndo() {
        context.read<ChatRepository>().undoDeleteChat(id: chat.id);
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.unsubscribedFrom(chat.name)),
          action: SnackBarAction(
            label: l10n.unsubscribedFromUndo,
            onPressed: _onUndo,
          ),
        ),
      );
    }

    void _onTap(String id) {
      context.goNamed(
        ChatPageName.chat.name,
        params: {'page': HomePageName.chats.name, 'id': id},
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appBarChats),
        actions: [
          IconButton(
            onPressed: _onAddPressed,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: context.read<ChatRepository>().getChatsListenamble(),
        builder: (context, _, __) {
          return ListView.builder(
            itemCount: context.read<ChatRepository>().getChatCount(),
            itemBuilder: (BuildContext context, int index) {
              final chat = context.read<ChatRepository>().getChatAt(
                    index: index,
                  );
              return Dismissible(
                key: ValueKey<String>(chat.id),
                onDismissed: (DismissDirection direction) => _onDismissed(chat),
                child: ChatView(
                  chat: chat,
                  onTap: () => _onTap(chat.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
