// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wubbachat/counter/counter.dart';
import 'package:flutter_wubbachat/fb_api/fb_api.dart';
import 'package:flutter_wubbachat/l10n/l10n.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterCubit(),
      child: const CounterView(),
    );
  }
}

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  Future<void> _sendSingle() async {
    // final token = await Fb.getToken();

    // final resp =
    //     await Fb.call<Map<String, dynamic>>('sendMessage', <String, String>{
    //   'text': 'A message sent from a client device',
    //   'token': token!,
    // });

    // print(resp.data);
  }

  Future<void> _subscribe() async {
    // await Fb.subscribeToTopic('sample_topic');
  }

  Future<void> _unsubscribe() async {
    // await Fb.unsubscribeFromTopic('sample_topic');
  }

  Future<void> _sendToTopic() async {
    // final resp = await Fb.call<Map<String, dynamic>>(
    //   'sendMessageToTopic',
    //   <String, String>{
    //     'text': 'A message sent from a client device to topic sample_topic',
    //     'topic': 'sample_topic',
    //   },
    // );

    // print(resp.data);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text('Smth')),
      body: const Center(child: CounterText()),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => context.read<CounterCubit>().increment(),
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () => context.read<CounterCubit>().decrement(),
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _sendSingle,
            child: const Icon(Icons.send),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _subscribe,
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: _unsubscribe,
            child: const Icon(Icons.remove),
          ),
          FloatingActionButton(
            onPressed: _sendToTopic,
            child: const Icon(Icons.send_time_extension),
          ),
        ],
      ),
    );
  }
}

class CounterText extends StatelessWidget {
  const CounterText({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = context.select((CounterCubit cubit) => cubit.state);
    return Text('$count', style: theme.textTheme.headline1);
  }
}
