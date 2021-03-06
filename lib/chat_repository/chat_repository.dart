import 'dart:developer';

import 'package:chat_storage/chat_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_wubbachat/chat_repository/cubit/deeproute_cubit.dart';
import 'package:flutter_wubbachat/fb_api/fb_api.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:words_api/words_api.dart';

export 'package:chat_storage/chat_storage.dart';

class ChatRepository {
  ChatRepository()
      : _fb = Fb(),
        _chatStorage = ChatStorage(),
        _wordsApi = WordsApi(),
        deepRouteCubit = DeepRouteCubit();

  final Fb _fb;
  final ChatStorage _chatStorage;
  final WordsApi _wordsApi;
  final DeepRouteCubit deepRouteCubit;

  Future<void> init() async {
    await _fb.init(
      onForegroundMessage: _onForegroundMessage,
      onBackgroundMessage: _onBackgroundMessage,
      onNotificationClick: _onNotificationClick,
    );

    await _chatStorage.init();
    await _wordsApi.init();
  }

  User getLocalUser() {
    var user = _chatStorage.getLocalUser();
    if (user == null) {
      user = createRandomUser();
      _chatStorage.setLocalUser(user: user);
    }
    return user;
  }

  Future<void> newLocalUser() async {
    final user = createRandomUser();
    await _chatStorage.setLocalUser(user: user);
  }

  ValueListenable<Box<User>> getLocalUserListenable() {
    return _chatStorage.getLocalUserListenable();
  }

  User createRandomUser() {
    final mood = toBeginningOfSentenceCase(_wordsApi.moodList.next.name);
    final colorKind = _wordsApi.colorList.next;
    final color = toBeginningOfSentenceCase(colorKind.name);
    final animal = toBeginningOfSentenceCase(_wordsApi.animalList.next.name);
    return User.create(
      nickname: '$mood $color $animal',
      color: colorKind.color,
    );
  }

  /// Create an empty chat and subscribe to topic
  Future<Chat> createRandomChat() async {
    final city = _wordsApi.cityList.next.name;
    final weater = toBeginningOfSentenceCase(_wordsApi.weatherList.next.name);

    final name = '$city. $weater';
    final chat = await _chatStorage.createChat(name: name);

    await _fb.subscribeToTopic(chat.toTopic());
    return chat;
  }

  /// Create an empty chat by topic subscribe to it
  Future<Chat> createChatFromTopic({required String topic}) async {
    final chat = await _chatStorage.createChatFromTopic(topic: topic);

    await _fb.subscribeToTopic(chat.toTopic());
    return chat;
  }

  int getChatCount({bool includeDeleted = false}) {
    return _chatStorage.getChatCount(includeDeleted: includeDeleted);
  }

  Chat getChatAt({required int index, bool includeDeleted = false}) {
    return _chatStorage.getChatAt(index: index, includeDeleted: includeDeleted);
  }

  /// Get chat by id
  Chat getChat({required String id}) {
    return _chatStorage.getChat(id: id);
  }

  /// Delete chat and unsubscribe from topic
  Future<void> deleteChat({
    required String id,
  }) async {
    final chat = await _chatStorage.markChatAsDeleted(id: id, deleted: true);
    await _fb.subscribeToTopic(chat.toTopic());
  }

  /// Delete chat and unsubscribe from topic
  Future<void> undoDeleteChat({
    required String id,
  }) async {
    final chat = await _chatStorage.markChatAsDeleted(id: id, deleted: false);
    await _fb.subscribeToTopic(chat.toTopic());
  }

  ValueListenable<Box<Chat>> getChatsListenamble() {
    return _chatStorage.getChatsListenamble();
  }

  ValueListenable<Box<Chat>> getChatListenamble({required String id}) {
    return _chatStorage.getChatListenamble(id: id);
  }

  List<Message> getChatMessages({required String id}) {
    return _chatStorage.getChatMessages(id: id);
  }

  Future<void> sendMessage({
    required String topic,
    required String body,
  }) async {
    final message = Message.create(user: getLocalUser(), body: body);
    final fields = remoteMessageFieldsFromMessage(message);

    await _chatStorage.putMessage(topic: topic, message: message);

    await _fb.sendMessageToTopic(topic, fields);
  }

  Future<void> _handleForegroundRemoteMessage({
    required RemoteMessage remoteMessage,
  }) async {
    try {
      final topic = topicFromRemoteMessage(remoteMessage);
      final message = messageFromRemoteMessage(remoteMessage);

      await _chatStorage.putMessage(
        topic: topic,
        message: message,
        onChatNotFound: () => _onChatNotFound(topic),
      );
    } catch (error) {
      log('handleForegroundRemoteMessage: $error');
    }
  }

  static Future<void> _handleBackgroundRemoteMessage({
    required RemoteMessage remoteMessage,
  }) async {
    try {
      final topic = topicFromRemoteMessage(remoteMessage);
      final message = messageFromRemoteMessage(remoteMessage);

      await ChatStorage.putBackgroundMessage(message: message, topic: topic);
    } catch (error) {
      log('handleBackgroundRemoteMessage: $error');
    }
  }

  Future<void> processBackgroundMessages() {
    return _chatStorage.processBackgroundMessages();
  }

  Future<void> serice() async {
    await _chatStorage.clearDeleted();
    _chatStorage.getChats().forEach((chat) async {
      await _fb.subscribeToTopic(chat.toTopic());
    });
  }

  Future<void> _onChatNotFound(String topic) async {
    await _fb.unsubscribeFromTopic(topic);
  }

  void _onForegroundMessage(RemoteMessage remoteMessage) {
    _handleForegroundRemoteMessage(remoteMessage: remoteMessage);
  }

  void _onNotificationClick(RemoteMessage remoteMessage) {
    final topic = topicFromRemoteMessage(remoteMessage);
    final id = ChatTopic.fromTopic(topic).id;

    try {
      // Ensure chat is available
      final chat = getChat(id: id);
      deepRouteCubit.setRoute(type: DeepRouteType.chat, route: chat.id);
    } catch (error) {
      log('_onNotificationClick: $error');
    }
  }

  static String topicFromRemoteMessage(RemoteMessage remoteMessage) {
    final topic = remoteMessage.from ?? remoteMessage.data['topic'] as String?;
    if (topic == null) {
      throw Exception('Error while constructing topic from RemoteMessage');
    }
    return topic;
  }

  static User userFromRemoteMessage(RemoteMessage remoteMessage) {
    final id = remoteMessage.data['fromId'] as String?;
    final nickname = remoteMessage.data['fromNickname'] as String?;
    final color = int.parse(remoteMessage.data['fromColor'] as String);
    if (id == null || nickname == null) {
      throw Exception('Error while constructing User from RemoteMessage');
    }
    return User(id: id, nickname: nickname, color: color);
  }

  static Message messageFromRemoteMessage(RemoteMessage remoteMessage) {
    final user = userFromRemoteMessage(remoteMessage);
    final id = remoteMessage.data['id'] as String?;
    final body = remoteMessage.data['messageBody'] as String?;
    if (body == null) {
      throw Exception('Error while constructing Message from RemoteMessage');
    }
    return Message.create(id: id, user: user, body: body);
  }

  static Map<String, String> remoteMessageFieldsFromMessage(Message message) {
    return {
      'id': message.id,
      'fromId': message.from.id,
      'fromNickname': message.from.nickname,
      'fromColor': message.from.color.toString(),
      'messageBody': message.body,
    };
  }
}

Future<void> _onBackgroundMessage(RemoteMessage remoteMessage) async {
  await Firebase.initializeApp();
  await ChatRepository._handleBackgroundRemoteMessage(
    remoteMessage: remoteMessage,
  );
}
