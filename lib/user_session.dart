import 'package:json_annotation/json_annotation.dart';

part 'user_session.g.dart';

@JsonSerializable()
class UserSession {
  final String username;
  final DateTime createdAt;
  const UserSession({
    required this.username,
    required this.createdAt,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) => _$UserSessionFromJson(json);
  Map<String, dynamic> toJson() => _$UserSessionToJson(this);
}
