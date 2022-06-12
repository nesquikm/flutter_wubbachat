// ignore_for_file: prefer_const_constructors, avoid_print
import 'package:chat_storage/chat_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final chatStorage = ChatStorage();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    MethodChannel(
      'plugins.flutter.io/path_provider_macos',
    ).setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getApplicationDocumentsDirectory':
          return 'hive_test/';
        default:
      }
    });

    await chatStorage.init();
  });

  group('ChatStorage', () {
    test('can be instantiated', () {
      expect(ChatStorage(), isNotNull);
    });
    test('store local user', () async {
      await chatStorage.clearAll();

      expect(chatStorage.getLocalUser(), isNull);
      final user = User.create(nickname: 'Some user');
      await chatStorage.setLocalUser(user: user);
      expect(chatStorage.getLocalUser(), user);
      await chatStorage.clearAll();
      expect(chatStorage.getLocalUser(), isNull);
    });
    test('store chat', () async {
      await chatStorage.clearAll();

      expect(chatStorage.getChatCount(), 0);
      await chatStorage.createChat(name: 'Some chat');
      expect(chatStorage.getChatCount(), 1);

      final chat = chatStorage.getChatAt(index: 0);
      expect(chat.name, 'Some chat');
      expect(chat.deleted, false);
      expect(chatStorage.getChat(id: chat.id).name, 'Some chat');

      await chatStorage.deleteChat(id: chat.id);
      expect(chatStorage.getChatCount(), 0);
    });
    test('sort chats', () async {
      await chatStorage.clearAll();

      expect(chatStorage.getChatCount(), 0);

      await chatStorage.createChat(name: 'Some chat C');
      await chatStorage.createChat(name: 'Some chat A');
      await chatStorage.createChat(name: 'Some chat D');
      await chatStorage.createChat(name: 'Some chat B');
      expect(chatStorage.getChatCount(), 4);

      expect(chatStorage.getChatAt(index: 0).name, 'Some chat A');
      expect(chatStorage.getChatAt(index: 1).name, 'Some chat B');
      expect(chatStorage.getChatAt(index: 2).name, 'Some chat C');
      expect(chatStorage.getChatAt(index: 3).name, 'Some chat D');
    });
    test('mark chat as deleted and clear deleted list', () async {
      await chatStorage.clearAll();

      expect(chatStorage.getChatCount(), 0);

      await chatStorage.createChat(name: 'A Some chat 0');
      expect(chatStorage.getChatCount(), 1);

      await chatStorage.createChat(name: 'B Some chat 1');
      expect(chatStorage.getChatCount(), 2);

      expect(chatStorage.getChatAt(index: 0).deleted, false);

      await chatStorage.markChatAsDeleted(
        id: chatStorage.getChatAt(index: 0).id,
        deleted: true,
      );

      expect(
        chatStorage.getChatAt(index: 0, includeDeleted: true).deleted,
        true,
      );
      expect(chatStorage.getChatCount(includeDeleted: true), 2);
      expect(chatStorage.getChatCount(), 1);

      await chatStorage.clearDeleted();

      expect(chatStorage.getChatCount(), 1);
    });
    test('store messages to a chat', () async {
      await chatStorage.clearAll();

      final user0 = User.create(nickname: 'Some nickname 0');
      final message0 = Message.create(user: user0, body: 'Some body 0');

      await chatStorage.putMessage(
        message: message0,
        topic: '123-456_Hello',
      );

      // Don't create a new chat from message
      expect(chatStorage.getChatCount(), 0);

      final chat = await chatStorage.createChat(name: 'Some chat 0');
      expect(chatStorage.getChatCount(), 1);

      await chatStorage.putMessage(
        message: message0,
        topic: chat.toTopic(),
      );

      final chat0 = chatStorage.getChatAt(index: 0);

      expect(chatStorage.getChatCount(), 1);
      expect(chat0.messages.length, 1);
      expect(chat0.messages[0].id, message0.id);
      expect(chat0.messages[0].body, 'Some body 0');
      expect(chat0.messages[0].from.id, user0.id);
      expect(chat0.name, 'Some chat 0');
      expect(chat0.id, chat.id);

      final user1 = User.create(nickname: 'Some nickname 1');
      final message1 = Message.create(user: user1, body: 'Some body 1');
      await chatStorage.putMessage(
        message: message1,
        topic: chat.toTopic(),
      );

      /// Don't create a new chat
      expect(chatStorage.getChatCount(), 1);

      final chat1 = chatStorage.getChat(id: chat0.id);

      expect(chat1.messages.length, 2);
      expect(chat0.messages[1].id, message1.id);
      expect(chat0.messages[1].body, 'Some body 1');
      expect(chat0.messages[1].from.id, user1.id);
      expect(chat0.name, 'Some chat 0');
      expect(chat0.id, chat.id);

      // Don't put existing messages
      await chatStorage.putMessage(
        message: message0,
        topic: chat.toTopic(),
      );
      await chatStorage.putMessage(
        message: message1,
        topic: chat.toTopic(),
      );
      expect(chat1.messages.length, 2);

      await chatStorage.createChat(name: 'Some chat 1');
      expect(chatStorage.getChatCount(), 2);
    });
  });
}
