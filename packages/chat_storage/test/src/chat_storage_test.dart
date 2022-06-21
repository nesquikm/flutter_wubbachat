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
      final user = User.create(nickname: 'Some user', color: 0xFF0000FF);
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
      expect(chatStorage.isChatExists(id: chat.id), true);

      await chatStorage.deleteChat(id: chat.id);
      expect(chatStorage.isChatExists(id: chat.id), false);
      expect(
          chatStorage.isChatExists(id: chat.id, includeDeleted: true), false);
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

      final id = chatStorage
          .getChatAt(
            index: 0,
          )
          .id;

      await chatStorage.markChatAsDeleted(
        id: id,
        deleted: true,
      );

      expect(
        chatStorage.isChatExists(
          id: id,
        ),
        false,
      );

      expect(
        chatStorage.isChatExists(
          id: id,
          includeDeleted: true,
        ),
        true,
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

      final user0 = User.create(nickname: 'Some nickname 0', color: 0xFF0000FF);
      final message0 = Message.create(user: user0, body: 'Some body 0');

      await chatStorage.putMessage(
        topic: '123-456_Hello',
        message: message0,
      );

      // Don't create a new chat from message
      expect(chatStorage.getChatCount(), 0);

      final chat = await chatStorage.createChat(name: 'Some chat 0');
      expect(chatStorage.getChatCount(), 1);

      await chatStorage.putMessage(
        topic: chat.toTopic(),
        message: message0,
      );

      final chat0 = chatStorage.getChatAt(index: 0);

      expect(chatStorage.getChatCount(), 1);
      expect(chat0.messages.length, 1);
      expect(chat0.messages[0].id, message0.id);
      expect(chat0.messages[0].body, 'Some body 0');
      expect(chat0.messages[0].from.id, user0.id);
      expect(chat0.name, 'Some chat 0');
      expect(chat0.id, chat.id);

      final user1 = User.create(nickname: 'Some nickname 1', color: 0xFF0000FF);
      final message1 = Message.create(user: user1, body: 'Some body 1');
      await chatStorage.putMessage(
        topic: chat.toTopic(),
        message: message1,
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
        topic: chat.toTopic(),
        message: message0,
      );
      await chatStorage.putMessage(
        topic: chat.toTopic(),
        message: message1,
      );
      expect(chat1.messages.length, 2);

      await chatStorage.createChat(name: 'Some chat 1');
      expect(chatStorage.getChatCount(), 2);
    });

    test('process background messages', () async {
      await chatStorage.clearAll();

      final chat0 = await chatStorage.createChat(name: 'Some chat 0');
      final chat1 = await chatStorage.createChat(name: 'Some chat 1');

      final user0 = User.create(nickname: 'Some nickname 0', color: 0xFF0000FF);
      final message0 = Message.create(user: user0, body: 'Some body 0');

      final message1 = Message.create(user: user0, body: 'Some body 1');

      final message2 = Message.create(user: user0, body: 'Some body 2');

      await ChatStorage.putBackgroundMessage(
        message: message0,
        topic: chat0.toTopic(),
      );

      expect(chatStorage.getChatMessages(id: chat0.id).length, 0);
      expect(chatStorage.getChatMessages(id: chat1.id).length, 0);

      await chatStorage.processBackgroundMessages();

      expect(chatStorage.getChatMessages(id: chat0.id).length, 1);
      expect(chatStorage.getChatMessages(id: chat1.id).length, 0);

      await ChatStorage.putBackgroundMessage(
        message: message1,
        topic: chat1.toTopic(),
      );

      await ChatStorage.putBackgroundMessage(
        message: message2,
        topic: chat1.toTopic(),
      );

      expect(chatStorage.getChatMessages(id: chat0.id).length, 1);
      expect(chatStorage.getChatMessages(id: chat1.id).length, 0);

      await chatStorage.processBackgroundMessages();

      expect(chatStorage.getChatMessages(id: chat0.id).length, 1);
      expect(chatStorage.getChatMessages(id: chat1.id).length, 2);
    });
  });
}
