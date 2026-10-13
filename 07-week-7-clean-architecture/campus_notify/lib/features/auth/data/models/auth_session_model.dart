import 'dart:convert';

import '../../domain/entities/auth_session.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.access,
    required super.refresh,
  });

  factory AuthSessionModel.fromMap(Map<String, dynamic> map) {
    return AuthSessionModel(
      access: map['access'] as String? ?? '',
      refresh: map['refresh'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'access': access,
      'refresh': refresh,
    };
  }

  factory AuthSessionModel.fromJson(String source) =>
      AuthSessionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  AuthSession toEntity() {
    return AuthSession(
      access: access,
      refresh: refresh,
    );
  }
}
