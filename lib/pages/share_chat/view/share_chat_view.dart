import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wubbachat/chat_repository/chat_repository.dart';
import 'package:flutter_wubbachat/l10n/l10n.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ShareChatView extends StatelessWidget {
  const ShareChatView({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final chat = context.read<ChatRepository>().getChat(id: id);

    void _onCopy() {
      Clipboard.setData(ClipboardData(text: chat.toTopic()));

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.chatIdCopied),
        ),
      );
    }

    void _onShare() {
      Share.share(
        chat.toTopic(),
        subject: l10n.youAreInvited(chat.name),
      );
      chat.toTopic();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shareChat),
        actions: [
          IconButton(onPressed: _onShare, icon: const Icon(Icons.share)),
          IconButton(onPressed: _onCopy, icon: const Icon(Icons.copy)),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(chat.name, style: theme.textTheme.headline5),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: QrImage(
              data: chat.toTopic(),
              size: 300,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
