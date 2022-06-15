// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_wubbachat/chat_repository/chat_repository.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

class AppLifecycleObserver extends StatefulWidget {
  const AppLifecycleObserver({
    super.key,
    required this.child,
    required this.onInactive,
    required this.onResumed,
  });

  final Widget child;
  final void Function() onInactive;
  final void Function() onResumed;

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        widget.onInactive();
        break;
      case AppLifecycleState.resumed:
        widget.onResumed();
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

Future<void> bootstrap(
  FutureOr<Widget> Function({
    required ChatRepository chatRepository,
  })
      builder,
) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  final chatRepository = ChatRepository();

  await chatRepository.init();

  final storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  await HydratedBlocOverrides.runZoned(
    () async => runApp(
      AppLifecycleObserver(
        onInactive: () async {},
        onResumed: () async {
          await chatRepository.processBackgroundMessages();
        },
        child: await builder(
          chatRepository: chatRepository,
        ),
      ),
    ),
    storage: storage,
    blocObserver: AppBlocObserver(),
  );
}
