import 'package:flutter/material.dart';
import 'package:flutter_wubbachat/chat_repository/chat_repository.dart';

class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.message,
    required this.fromLocalUser,
  });

  final Message message;
  final bool fromLocalUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(message.from.color | 0xFF000000);
    final rowChildren = [
      Container(
        margin: const EdgeInsets.only(top: 4, left: 4, right: 4),
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      Expanded(
        child: Card(
          child: ListTile(
            minVerticalPadding: 16,
            title: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                message.from.nickname,
                style: theme.textTheme.bodySmall!.merge(
                  TextStyle(color: color),
                ),
              ),
            ),
            subtitle: Text(message.body),
          ),
        ),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fromLocalUser ? rowChildren.reversed.toList() : rowChildren,
      ),
    );
  }
}
