import 'package:fluttea/core/errors/result.dart';
import 'package:fluttea/core/storage/secure/secure_storage.dart';
import 'package:fluttea/features/auth/data/auth_api.dart';
import 'package:fluttea/features/auth/data/dto/login_request_dto.dart';
import 'package:fluttea/features/auth/data/dto/login_response_dto.dart';
import 'package:fluttea/features/auth/domain/models/user.dart';

abstract interface class AuthRepository {
  Future<Result<User>> login({required String email, required String password});
  Future<Result<void>> logout();
  Future<Result<User?>> restoreSession();
}

final class AuthRepositoryImpl implements AuthRepository {
  const new(this._api, this._secureStorage);

  final AuthApi _api;
  final SecureStorage _secureStorage;

  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUserName = 'auth_user_name';
  static const String _keyUserEmail = 'auth_user_email';
  static const String _keyUserRole = 'auth_user_role';

  @override
  Future<Result<User>> login({required String email, required String password}) async {
    final result = await _api.login(LoginRequestDto(email: email, password: password));

    return switch (result) {
      Ok(:final value) => await _persistUser(value),
      Err(:final failure) => Result<User>.err(failure),
    };
  }

  Future<Result<User>> _persistUser(LoginResponseDto value) async {
    await _secureStorage.write(_keyToken, value.token);
    await _secureStorage.write(_keyUserId, value.userId);
    await _secureStorage.write(_keyUserName, value.name);
    await _secureStorage.write(_keyUserEmail, value.email);
    await _secureStorage.write(_keyUserRole, value.role);
    return Result<User>.ok(value.toDomain());
  }

  @override
  Future<Result<void>> logout() async {
    final token = await _secureStorage.read(_keyToken);
    if (token != null && token.isNotEmpty) {
      try {
        await _api.logout(token);
      } on Object catch (_) {}
    }

    await _secureStorage.delete(_keyToken);
    await _secureStorage.delete(_keyUserId);
    await _secureStorage.delete(_keyUserName);
    await _secureStorage.delete(_keyUserEmail);
    await _secureStorage.delete(_keyUserRole);

    return const Result.ok(null);
  }

  @override
  Future<Result<User?>> restoreSession() async {
    final token = await _secureStorage.read(_keyToken);
    final userId = await _secureStorage.read(_keyUserId);
    final email = await _secureStorage.read(_keyUserEmail);
    final name = await _secureStorage.read(_keyUserName) ?? 'User';
    final role = await _secureStorage.read(_keyUserRole) ?? 'user';

    if (token != null && token.isNotEmpty && userId != null && userId.isNotEmpty) {
      return Result.ok(User(id: userId, name: name, email: email ?? '', role: role));
    }

    return const Result.ok(null);
  }
}
