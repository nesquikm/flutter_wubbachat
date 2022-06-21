import 'package:chat_storage/src/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// {@template chat_storage}
/// Chat storage
/// {@endtemplate}
class ChatStorage {
  /// {@macro chat_storage}
  ChatStorage();

  /// We can't use LazyBox because HiveList is not support it yet
  /// https://github.com/hivedb/hive/issues/866
  late final Box<Message> _messagesBox;
  late final Box<Chat> _chatsBox;
  late final Box<User> _localUserBox;

  /// Init all
  Future<void> init() async {
    await _initHive();

    _messagesBox = await Hive.openBox<Message>(_messagesBoxName);
    _chatsBox = await Hive.openBox<Chat>(_chatsBoxName);
    _localUserBox = await Hive.openBox<User>(_localUserBoxName);
  }

  static Future<void> _initHive() async {
    await Hive.initFlutter();

    _checkRegisterAdapter<User>(UserAdapter());
    _checkRegisterAdapter<Message>(MessageAdapter());
    _checkRegisterAdapter<Chat>(ChatAdapter());
    _checkRegisterAdapter<BackgroundMessage>(BackgroundMessageAdapter());
  }

  static void _checkRegisterAdapter<T>(TypeAdapter<T> adapter) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter<T>(adapter);
    }
  }

  /// Get local user
  User? getLocalUser() {
    return _localUserBox.get(_localUserKey);
  }

  /// Set local user
  Future<void> setLocalUser({required User user}) async {
    return _localUserBox.put(_localUserKey, user);
  }

  /// Get listenable for local user
  ValueListenable<Box<User>> getLocalUserListenable() {
    return _localUserBox.listenable(keys: [_localUserKey].toList());
  }

  /// Put message to the storage (create chat and user if necessary)
  Future<void> putMessage({
    required String topic,
    required Message message,
    void Function()? onChatNotFound,
  }) async {
    /// We don't update existing messages
    if (_messagesBox.containsKey(message.id)) return;

    // We don't create a new chat
    final chat = _chatsBox.get(ChatTopic.fromTopic(topic).id);
    if (chat == null) {
      onChatNotFound?.call();
      return;
    }

    await _messagesBox.put(message.id, message);
    chat.messages.add(message);
    await _putChat(chat: chat);
  }

  /// Get sorted chat messages
  List<Message> getChatMessages({required String id}) {
    final list = getChat(id: id).messages
      ..sort(
        (messageA, messageB) => messageA.received.compareTo(messageB.received),
      );
    return list;
  }

  /// Create an empty chat
  Future<Chat> createChat({required String name}) async {
    final chat = Chat.create(name: name, messagesBox: _messagesBox);
    return _putChat(chat: chat);
  }

  /// Create an chat from topic
  Future<Chat> createChatFromTopic({required String topic}) async {
    final chat = Chat.fromTopic(topic: topic, messagesBox: _messagesBox);
    return _putChat(chat: chat);
  }

  /// Put chat
  Future<Chat> _putChat({required Chat chat}) async {
    await _chatsBox.put(chat.id, chat);
    return chat;
  }

  /// Get chat list
  List<Chat> _getChats({bool includeDeleted = false}) {
    return includeDeleted
        ? _chatsBox.values.toList()
        : _chatsBox.values.where((chat) => !chat.deleted).toList();
  }

  /// Get sorted chat list
  List<Chat> getChats({bool includeDeleted = false}) {
    final list = _getChats(includeDeleted: includeDeleted)
      ..sort((chatA, chatB) => chatA.name.compareTo(chatB.name));
    return list;
  }

  /// Get chat count
  int getChatCount({bool includeDeleted = false}) {
    return _getChats(includeDeleted: includeDeleted).length;
  }

  /// Get chat by position
  Chat getChatAt({required int index, bool includeDeleted = false}) {
    return getChats(includeDeleted: includeDeleted)[index];
  }

  /// Get chat by id
  Chat getChat({required String id}) {
    return _chatsBox.get(id)!;
  }

  /// Get listenable for the chat by id
  ValueListenable<Box<Chat>> getChatsListenamble() {
    return _chatsBox.listenable();
  }

  /// Get listenable for the chat by id
  ValueListenable<Box<Chat>> getChatListenamble({required String id}) {
    return _chatsBox.listenable(keys: [id].toList());
  }

  /// Mark chat as deleted
  Future<Chat> markChatAsDeleted({
    required String id,
    required bool deleted,
  }) async {
    final chat = _chatsBox.get(id);
    await _putChat(chat: chat!.copyWith(deleted: deleted));
    return chat;
  }

  /// Delete chat
  Future<void> deleteChat({required String id}) async {
    final chat = _chatsBox.get(id);
    if (chat == null) return;
    await _messagesBox.deleteAll(chat.messages.keys);
    await _chatsBox.delete(id);
  }

  /// Delete all marked as deleted
  Future<void> clearDeleted() async {
    for (final chat in _chatsBox.values) {
      if (chat.deleted) {
        await deleteChat(id: chat.id);
      }
    }
  }

  /// Clear local storage
  Future<void> clearAll() async {
    await _localUserBox.clear();
    await _messagesBox.clear();
    await _chatsBox.clear();
  }

  static Future<Box<BackgroundMessage>> _openBackgroundMessagesBox() async {
    await _initHive();

    return Hive.openBox<BackgroundMessage>(_backgroundMessagesBoxName);
  }

  static Future<void> _closeBackgroundMessagesBox(
    Box<BackgroundMessage> backgroundMessagesBox,
  ) async {
    await backgroundMessagesBox.close();
  }

  /// Put background message to the storage
  static Future<void> putBackgroundMessage({
    required Message message,
    required String topic,
  }) async {
    final backgroundMessagesBox = await _openBackgroundMessagesBox();

    await backgroundMessagesBox.add(
      BackgroundMessage(
        topic: topic,
        message: message,
      ),
    );

    await _closeBackgroundMessagesBox(backgroundMessagesBox);
  }

  /// Process background messages
  Future<void> processBackgroundMessages() async {
    final backgroundMessagesBox = await _openBackgroundMessagesBox();

    for (final backgroundMessage in backgroundMessagesBox.values) {
      await putMessage(
        topic: backgroundMessage.topic,
        message: backgroundMessage.message,
      );
    }

    await backgroundMessagesBox.clear();
    await _closeBackgroundMessagesBox(backgroundMessagesBox);
  }

  static const _messagesBoxName = 'messages';
  static const _chatsBoxName = 'chats';
  static const _localUserBoxName = 'localUser';
  static const _localUserKey = 'localUserKey';
  static const _backgroundMessagesBoxName = 'backgroundMessages';
}
