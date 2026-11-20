import 'dart:async';

import 'package:fluttea/app/providers.dart';
import 'package:fluttea/core/errors/result.dart';
import 'package:fluttea/core/network/network_providers.dart';
import 'package:fluttea/core/state/session_state_provider.dart';
import 'package:fluttea/features/auth/data/auth_api.dart';
import 'package:fluttea/features/auth/data/auth_repository.dart';
import 'package:fluttea/features/auth/domain/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthApiImpl(client);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.watch(authApiProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(api, secureStorage);
});

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  FutureOr<User?> build() => null;

  Future<bool> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.login(email: email, password: password);

    if (!ref.mounted) return false;

    switch (result) {
      case Ok(:final value):
        ref
            .read(sessionProvider.notifier)
            .login(userId: value.id, token: 'token_${value.id}', email: value.email);
        state = AsyncValue.data(value);
        return true;
      case Err(:final failure):
        state = AsyncValue.error(failure, failure.stackTrace ?? StackTrace.current);
        return false;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    if (!ref.mounted) return;
    ref.read(sessionProvider.notifier).logout();
    state = const AsyncValue.data(null);
  }

  Future<User?> restoreSession() async {
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.restoreSession();
    if (!ref.mounted) return null;
    return switch (result) {
      Ok(:final value) => () {
        if (value != null) {
          ref
              .read(sessionProvider.notifier)
              .login(userId: value.id, token: 'restored_${value.id}', email: value.email);
          state = AsyncValue.data(value);
        }
        return value;
      }(),
      Err() => null,
    };
  }
}

final AsyncNotifierProvider<AuthNotifier, User?> authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);
