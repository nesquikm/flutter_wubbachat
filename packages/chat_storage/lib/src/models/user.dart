import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'user.g.dart';

/// {@template user}
/// User model
/// {@endtemplate}
@HiveType(typeId: 0)
class User extends HiveObject {
  /// {@macro user}
  User({required this.id, required this.nickname, required this.color});

  /// Create user info
  factory User.create({required String nickname, required int color}) =>
      User(id: const Uuid().v4(), nickname: nickname, color: color);

  /// User id
  @HiveField(0)
  final String id;

  /// User nickname
  @HiveField(1)
  final String nickname;

  /// User id
  @HiveField(2)
  final int color;
}
