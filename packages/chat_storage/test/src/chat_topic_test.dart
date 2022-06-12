// ignore_for_file: prefer_const_constructors
import 'package:chat_storage/src/models/chat_topic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatTopic', () {
    test('can be instantiated', () {
      expect(ChatTopic(id: 'id', name: 'name'), isNotNull);
    });
    test('correct convert name and id in both direction', () {
      const id = '123-456';
      const name = 'Bërdica e Madhe Привет';
      expect(
        ChatTopic.fromTopic(ChatTopic(id: id, name: name).toTopic()).id,
        id,
      );
      expect(
        ChatTopic.fromTopic(ChatTopic(id: id, name: name).toTopic()).name,
        name,
      );
    });
    test('match topic regexp', () {
      const id = '123-456-789';
      const name = 'Bërdica e Madhe Привет %погодка% :)';
      expect(
        RegExp(r'^[a-zA-Z0-9-_.~%]{1,900}$').hasMatch(
          ChatTopic(id: id, name: name).toTopic(),
        ),
        true,
      );
    });
  });
}
