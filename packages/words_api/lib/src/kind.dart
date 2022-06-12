/// {@template kind}
/// A simple thing for storing strings
/// {@endtemplate}
class Kind {
  /// {@macro kind}
  Kind(Map<String, dynamic> map) : name = map['name'] as String;

  /// Stored string
  final String name;
}
