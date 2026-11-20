import 'package:fluttea/core/errors/result.dart';
import 'package:fluttea/core/network/api_client.dart';
import 'package:fluttea/features/auth/data/dto/login_request_dto.dart';
import 'package:fluttea/features/auth/data/dto/login_response_dto.dart';

abstract interface class AuthApi {
  Future<Result<LoginResponseDto>> login(LoginRequestDto request);
  Future<Result<void>> logout(String token);
}

final class AuthApiImpl implements AuthApi {
  const new(this._client);

  final ApiClient _client;

  @override
  Future<Result<LoginResponseDto>> login(LoginRequestDto request) async {
    return await _client.request<LoginResponseDto>(
      HttpMethod.post,
      '/auth/login',
      data: request.toJson(),
      fromJson: (json) => LoginResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Result<void>> logout(String token) async {
    return await _client.request<void>(
      HttpMethod.post,
      '/auth/logout',
      headers: <String, dynamic>{'Authorization': 'Bearer $token'},
    );
  }
}
