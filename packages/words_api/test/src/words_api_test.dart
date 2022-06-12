// ignore_for_file: prefer_const_constructors, avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:words_api/words_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('WordsApi', () {
    test('can be instantiated', () {
      expect(WordsApi(), isNotNull);
    });

    test('is properly initialized', () async {
      final api = WordsApi();
      await api.init();
      expect(api.animalList.length > 0, isTrue);
      expect(api.cityList.length > 0, isTrue);
      expect(api.colorList.length > 0, isTrue);
      expect(api.moodList.length > 0, isTrue);
      expect(api.weatherList.length > 0, isTrue);
    });

    test('return a string', () async {
      final api = WordsApi();
      await api.init();
      expect(api.animalList.next.name, isNotEmpty);
      expect(api.cityList.next.name, isNotEmpty);
      expect(api.colorList.next.name, isNotEmpty);
      expect(api.moodList.next.name, isNotEmpty);
      expect(api.weatherList.next.name, isNotEmpty);

      print('Animal length ${api.animalList.length}');
      print('City length ${api.cityList.length}');
      print('Color length ${api.colorList.length}');
      print('Mood length ${api.moodList.length}');
      print('Weather length ${api.weatherList.length}');

      print('Animal ${api.animalList.next.name}');
      print('Animal ${api.animalList.next.name}');
      print('Animal ${api.animalList.next.name}');

      print('City ${api.cityList.next.name}');
      print('City ${api.cityList.next.name}');
      print('City ${api.cityList.next.name}');

      print('Color ${api.colorList.next.name}');
      print('Color ${api.colorList.next.name}');
      print('Color ${api.colorList.next.name}');
      print('Color ${api.colorList.next.color}');
      print('Color ${api.colorList.next.color}');
      print('Color ${api.colorList.next.color}');

      print('Mood ${api.moodList.next.name}');
      print('Mood ${api.moodList.next.name}');
      print('Mood ${api.moodList.next.name}');

      print('Weather ${api.weatherList.next.name}');
      print('Weather ${api.weatherList.next.name}');
      print('Weather ${api.weatherList.next.name}');
    });
  });
}
