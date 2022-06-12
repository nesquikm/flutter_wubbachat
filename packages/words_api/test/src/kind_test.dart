// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:words_api/src/kind.dart';

void main() {
  test('Kind base fields', () {
    final a = Kind(<String, String>{
      'name': 'Some kind name',
      'some_other_shit': 'Just something'
    });

    expect(a.name, 'Some kind name');
  });
}
