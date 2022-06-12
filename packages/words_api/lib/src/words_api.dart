import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:words_api/src/color_kind.dart';
import 'package:words_api/src/kind.dart';
import 'package:words_api/src/kind_list.dart';

/// {@template words_api}
/// Words package
/// {@endtemplate}
class WordsApi {
  /// {@macro words_api}
  WordsApi();

  late KindList<Kind> _animalList;
  late KindList<Kind> _cityList;
  late KindList<ColorKind> _colorList;
  late KindList<Kind> _moodList;
  late KindList<Kind> _weatherList;

  /// Get animal list
  KindList<Kind> get animalList {
    return _animalList;
  }

  /// Get city list
  KindList<Kind> get cityList {
    return _cityList;
  }

  /// Get color list
  KindList<ColorKind> get colorList {
    return _colorList;
  }

  /// Get mood list
  KindList<Kind> get moodList {
    return _moodList;
  }

  /// Get weather list
  KindList<Kind> get weatherList {
    return _weatherList;
  }

  Future<List> _loadFromJson(String key) async {
    return json.decode(
      await rootBundle.loadString('packages/words_api/assets/$key'),
    ) as List;
  }

  Future<List<Kind>> _kindFromJson(String key) async {
    return List<Kind>.from(
      (await _loadFromJson(key))
          .map<Kind>((dynamic e) => Kind(e as Map<String, dynamic>)),
    );
  }

  Future<List<ColorKind>> _colorKindFromJson(String key) async {
    return List<ColorKind>.from(
      (await _loadFromJson(key))
          .map<ColorKind>((dynamic e) => ColorKind(e as Map<String, dynamic>)),
    );
  }

  /// Init all
  Future<void> init() async {
    _animalList = KindList<Kind>(
      await _kindFromJson(
        'animal_list.json',
      ),
    );
    _cityList = KindList<Kind>(
      await _kindFromJson(
        'city_list.json',
      ),
    );
    _colorList = KindList<ColorKind>(
      await _colorKindFromJson(
        'color_list.json',
      ),
    );
    _moodList = KindList<Kind>(
      await _kindFromJson(
        'mood_list.json',
      ),
    );
    _weatherList = KindList<Kind>(
      await _kindFromJson(
        'weather_list.json',
      ),
    );
  }
}
