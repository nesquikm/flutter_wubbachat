import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wubbachat/chat_repository/chat_repository.dart';
import 'package:flutter_wubbachat/l10n/l10n.dart';
import 'package:flutter_wubbachat/pages/chat/view/message_view.dart';
import 'package:flutter_wubbachat/pages/pages.dart';
import 'package:go_router/go_router.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key, required this.id});

  final String id;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late final TextEditingController _textEditingController;
  late final ScrollController _listScrollController;

  @override
  void initState() {
    super.initState();

    _textEditingController = TextEditingController();
    _listScrollController = ScrollController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();

    super.dispose();
  }

  void _onSend(BuildContext context) {
    final chat = context.read<ChatRepository>().getChat(id: widget.id);
    context
        .read<ChatRepository>()
        .sendMessage(topic: chat.toTopic(), body: _textEditingController.text);
    _textEditingController.clear();
    _listScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget buildInput({required BuildContext context}) {
    final l10n = context.l10n;

    return SizedBox(
      width: double.infinity,
      height: 64,
      child: Row(
        children: [
          Flexible(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: TextField(
                onSubmitted: (value) => _onSend(context),
                controller: _textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: l10n.chatMessageHint,
                ),
                maxLength: 768,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _onSend(context),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void _onSharePressed() {
      context.goNamed(
        ChatPageName.sharechat.name,
        params: {'page': HomePageName.chats.name, 'id': widget.id},
      );
    }

    final localUser = context.read<ChatRepository>().getLocalUser();

    return ValueListenableBuilder(
      valueListenable:
          context.read<ChatRepository>().getChatListenamble(id: widget.id),
      builder: (context, _, __) {
        final chat = context.read<ChatRepository>().getChat(id: widget.id);
        final messages =
            context.read<ChatRepository>().getChatMessages(id: widget.id);
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
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  controller: _listScrollController,
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final resversedIndex = messages.length - index - 1;
                    final message = messages[resversedIndex];
                    return MessageView(
                      message: message,
                      fromLocalUser: localUser.id == message.from.id,
                    );
                  },
                ),
              ),
              buildInput(context: context),
            ],
          ),
        );
      },
    );
  }
}
