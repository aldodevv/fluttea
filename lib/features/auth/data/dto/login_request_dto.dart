import 'package:flutter/foundation.dart';

@immutable
final class LoginRequestDto {
  const new({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => <String, dynamic>{'email': email, 'password': password};
}
