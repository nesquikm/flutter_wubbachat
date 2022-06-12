// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:words_api/src/color_kind.dart';

void main() {
  test('ColorKind base fields', () {
    final a = ColorKind(<String, String>{
      'name': 'Some kind name',
      'color': '#ff00ff',
      'some_other_shit': 'Just something'
    });

    expect(a.name, 'Some kind name');
    expect(a.color, 16711935);
  });
}
