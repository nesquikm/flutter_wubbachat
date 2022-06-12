import 'package:flutter/material.dart';
import 'package:flutter_wubbachat/pages/share_chat/view/share_chat_view.dart';

class ShareChatPage extends StatelessWidget {
  const ShareChatPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return ShareChatView(id: id);
  }
}
