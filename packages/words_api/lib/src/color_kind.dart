import 'package:words_api/src/kind.dart';

/// {@template color_kind}
/// A bit more complex (than kind) thing for storing colors
/// {@endtemplate}
class ColorKind extends Kind {
  /// {@macro color_kind}
  ColorKind(super.map)
      : color = int.parse(
          (map['color'] as String).replaceFirst('#', ''),
          radix: 16,
        );

  /// Stored color
  final int color;
}
