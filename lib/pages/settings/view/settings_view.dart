import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wubbachat/chat_repository/chat_repository.dart';
import 'package:flutter_wubbachat/l10n/l10n.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  void _onChangeIdentityPressed(BuildContext context) {
    context.read<ChatRepository>().newLocalUser();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appBarSettings),
      ),
      body: ValueListenableBuilder(
        valueListenable:
            context.read<ChatRepository>().getLocalUserListenable(),
        builder: (BuildContext context, _, __) {
          final user = context.read<ChatRepository>().getLocalUser();
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 32, bottom: 32),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(user.color | 0xFF000000),
                    shape: BoxShape.circle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      user.nickname,
                      style: theme.textTheme.headline5,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => _onChangeIdentityPressed(context),
                  child: Text(l10n.changeIdentity),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
