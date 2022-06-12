import 'dart:math';

import 'package:words_api/src/kind.dart';

/// {@template kind_list}
/// A list that can provide a random item
/// {@endtemplate}
class KindList<T extends Kind> {
  /// {@macro kind_list}
  KindList(this._list) : _random = Random.secure();

  final List<T> _list;
  final Random _random;

  /// The number of objects in this list
  int get length {
    return _list.length;
  }

  /// A random item from the list
  T get next {
    return _list[_random.nextInt(_list.length)];
  }
}
