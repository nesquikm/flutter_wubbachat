import 'package:chat_storage/src/models/message.dart';
import 'package:hive/hive.dart';

part 'background_message.g.dart';

/// {@template message}
/// Message model
/// {@endtemplate}
@HiveType(typeId: 3)
class BackgroundMessage extends HiveObject {
  /// {@macro message}
  BackgroundMessage({
    required this.topic,
    required this.message,
  });

  /// Message id
  @HiveField(0)
  final String topic;

  /// Author
  @HiveField(1)
  final Message message;
}
