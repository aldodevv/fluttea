import 'package:fluttea/features/auth/domain/models/user.dart';
import 'package:flutter/foundation.dart';

@immutable
final class LoginResponseDto {
  const new({
    required this.token,
    required this.userId,
    required this.name,
    required this.email,
    this.role = 'user',
    this.expiresIn,
  });

  factory fromJson(Map<String, dynamic> json) {
    final userData = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;

    return LoginResponseDto(
      token: (json['token'] ?? json['accessToken'] ?? '') as String,
      userId: (userData['id'] ?? userData['userId'] ?? '') as String,
      name: (userData['name'] ?? userData['username'] ?? '') as String,
      email: (userData['email'] ?? '') as String,
      role: (userData['role'] ?? 'user') as String,
      expiresIn: json['expiresIn'] as int?,
    );
  }

  final String token;
  final String userId;
  final String name;
  final String email;
  final String role;
  final int? expiresIn;

  User toDomain() => User(id: userId, name: name, email: email, role: role);
}
