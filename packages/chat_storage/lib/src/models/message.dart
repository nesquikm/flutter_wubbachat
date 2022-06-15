import 'package:chat_storage/src/models/user.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'message.g.dart';

/// {@template message}
/// Message model
/// {@endtemplate}
@HiveType(typeId: 1)
class Message extends HiveObject {
  /// {@macro message}
  Message({
    required this.id,
    required this.from,
    required this.body,
    required this.received,
  });

  /// Create new chat message
  factory Message.create({
    String? id,
    required User user,
    required String body,
    int? received,
  }) =>
      Message(
        id: id ?? const Uuid().v4(),
        from: user,
        body: body,
        received: received ?? DateTime.now().millisecondsSinceEpoch,
      );

  /// Message id
  @HiveField(0)
  final String id;

  /// Author
  @HiveField(1)
  final User from;

  /// Body
  @HiveField(2)
  final String body;

  /// Received timestamp
  @HiveField(3)
  final int received;
}
