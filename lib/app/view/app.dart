// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_wubbachat/app/cubit/nav_cubit.dart';
import 'package:flutter_wubbachat/chat_repository/chat_repository.dart';
import 'package:flutter_wubbachat/l10n/l10n.dart';
import 'package:flutter_wubbachat/pages/pages.dart';
import 'package:go_router/go_router.dart';

class App extends StatelessWidget {
  const App({super.key, required this.chatRepository});

  final ChatRepository chatRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: chatRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => NavCubit('/${HomePage.pageList[0]}'),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/:page',
          name: 'home',
          builder: (context, state) =>
              HomePage(pageName: state.params['page'] ?? ''),
          routes: [
            GoRoute(
              path: 'chat/:id',
              name: ChatPageName.chat.name,
              builder: (context, state) =>
                  ChatPage(id: state.params['id'] ?? ''),
              routes: [
                GoRoute(
                  path: 'sharechat',
                  name: ChatPageName.sharechat.name,
                  builder: (context, state) =>
                      ShareChatPage(id: state.params['id'] ?? ''),
                ),
              ],
            ),
          ],
        ),
      ],
      redirect: (state) {
        context.read<NavCubit>().setLocation(state.location);

        return null;
      },
      initialLocation: context.read<NavCubit>().state.location,
      debugLogDiagnostics: true,
    );

    return MaterialApp.router(
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
