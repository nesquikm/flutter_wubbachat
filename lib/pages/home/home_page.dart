import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_wubbachat/l10n/l10n.dart';
import 'package:flutter_wubbachat/pages/pages.dart';
import 'package:go_router/go_router.dart';

enum HomePageName {
  chats,
  settings,
}

enum ChatPageName {
  chat,
  sharechat,
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.pageName});

  static List<String> pageList =
      HomePageName.values.map((e) => e.name).toList();

  final String pageName;

  int get _pageIndex {
    return max(pageList.indexOf(pageName), 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    void _onTagSelected(int index) {
      context.goNamed('home', params: {'page': pageList[index]});
    }

    return Scaffold(
      body: IndexedStack(
        index: _pageIndex,
        children: const [ChatsPage(), SettingsPage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat),
            label: l10n.navBarChats,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.navBarSettings,
          ),
        ],
        currentIndex: _pageIndex,
        onTap: _onTagSelected,
      ),
    );
  }
}
