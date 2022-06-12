import 'package:chat_storage/src/models/chat_topic.dart';
import 'package:chat_storage/src/models/message.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'chat.g.dart';

/// {@template chat}
/// Chat model
/// {@endtemplate}
@HiveType(typeId: 2)
class Chat extends HiveObject {
  /// {@macro chat}
  Chat({
    required this.name,
    required this.id,
    required this.messages,
    this.deleted = false,
  });

  /// Create chat from topic
  factory Chat.fromTopic({required String topic, required Box messagesBox}) {
    final chatTopic = ChatTopic.fromTopic(topic);
    return Chat(
      id: chatTopic.id,
      name: chatTopic.name,
      messages: HiveList<Message>(
        messagesBox,
      ),
    );
  }

  /// Create new chat
  factory Chat.create({required String name, required Box messagesBox}) => Chat(
        name: name,
        id: const Uuid().v4(),
        messages: HiveList<Message>(messagesBox),
      );

  /// Copy chat object with modifications
  Chat copyWith({
    String? name,
    String? id,
    HiveList<Message>? messages,
    bool? deleted,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      messages: messages ?? this.messages,
      deleted: deleted ?? this.deleted,
    );
  }

  /// Chat name
  @HiveField(0)
  final String name;

  /// Chat id
  @HiveField(1)
  final String id;

  /// Chat message list
  @HiveField(2)
  final HiveList<Message> messages;

  /// Chat is deleted
  @HiveField(3)
  final bool deleted;

  /// Construct chat topic
  String toTopic() {
    return ChatTopic.constructTopic(id: id, name: name);
  }
}
