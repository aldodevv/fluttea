import 'package:flutter/foundation.dart';

@immutable
final class User {
  const new({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.role == role &&
        other.avatarUrl == avatarUrl;
  }

  @override
  int get hashCode => Object.hash(id, name, email, role, avatarUrl);

  @override
  String toString() =>
      'User(id: $id, name: $name, email: $email, role: $role, avatarUrl: $avatarUrl)';
}
