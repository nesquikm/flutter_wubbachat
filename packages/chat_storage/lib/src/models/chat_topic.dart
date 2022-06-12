/// {@template chat}
/// Chat topic helper chat_topic
/// {@endtemplate}
class ChatTopic {
  /// {@macro chat_topic}
  const ChatTopic({required this.id, required this.name});

  /// Create from tiopic
  factory ChatTopic.fromTopic(String topic) {
    final expTopic = RegExp('([0-9a-zA-Z-]+)_(.*)');
    final matchTopic = expTopic.firstMatch(_decodeTopic(topic));

    final id = matchTopic?[1];
    final name = matchTopic?[2];

    if (id == null || name == null) {
      throw Exception('Error while parsing topic');
    }

    return ChatTopic(
      id: id,
      name: name,
    );
  }

  /// Convert to chat topic
  String toTopic() {
    return constructTopic(id: id, name: name);
  }

  /// Construct chat topic
  static String constructTopic({required String id, required String name}) {
    return _encodeTopic('${id}_$name')
        .replaceAll(RegExp('[^a-zA-Z0-9-_.~%]'), '_');
  }

  /// Chat id
  final String id;

  /// Chat name
  final String name;

  static String _decodeTopic(String encodedTopic) {
    return Uri.decodeFull(encodedTopic);
  }

  static String _encodeTopic(String topic) {
    return Uri.encodeFull(topic);
  }
}
