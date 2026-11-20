import 'package:fluttea/app/app.dart';
import 'package:fluttea/app/flavor.dart';
import 'package:fluttea/app/providers.dart';
import 'package:fluttea/core/errors/result.dart';
import 'package:fluttea/core/storage/secure/secure_storage.dart';
import 'package:fluttea/features/auth/data/auth_api.dart';
import 'package:fluttea/features/auth/data/dto/login_request_dto.dart';
import 'package:fluttea/features/auth/data/dto/login_response_dto.dart';
import 'package:fluttea/features/auth/state/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _MockAuthApi implements AuthApi {
  @override
  Future<Result<LoginResponseDto>> login(LoginRequestDto request) async {
    return Result.ok(
      LoginResponseDto(
        token: 'wt_jwt_token_123',
        userId: 'wt_user_1',
        name: 'Demo User',
        email: request.email,
      ),
    );
  }

  @override
  Future<Result<void>> logout(String token) async {
    return const Result.ok(null);
  }
}

class _InMemorySecureStorage extends SecureStorage {
  final Map<String, String> _map = {};

  @override
  Future<String?> read(String key) async => _map[key];

  @override
  Future<void> write(String key, String value) async {
    _map[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _map.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _map.clear();
  }

  @override
  Future<bool> containsKey(String key) async => _map.containsKey(key);

  @override
  Future<Map<String, String>> readAll() async => Map.unmodifiable(_map);
}

void main() {
  testWidgets('full login and logout flow end-to-end', (tester) async {
    final env = AppEnv.of(AppFlavor.dev);
    final mockAuthApi = _MockAuthApi();
    final inMemoryStorage = _InMemorySecureStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(env),
          authApiProvider.overrideWithValue(mockAuthApi),
          secureStorageProvider.overrideWithValue(inMemoryStorage),
        ],
        child: const App(),
      ),
    );

    // 1. Initial Splash -> Login Screen transition
    await tester.pumpAndSettle();
    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);

    // 2. Fill demo credentials
    await tester.tap(find.text('Isi Kredensial Demo'));
    await tester.pumpAndSettle();
    expect(find.text('demo@fluttea.dev'), findsOneWidget);

    // 3. Submit Login Form
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    // 4. Verify Home Screen loaded with authenticated user greeting
    expect(find.text('Halo, demo@fluttea.dev!'), findsOneWidget);
    expect(find.text(env.baseUrl), findsOneWidget);

    // 5. Navigate to Settings Screen via AppBar action
    final settingsActionFinder = find.byIcon(Icons.settings_outlined);
    expect(settingsActionFinder, findsWidgets);
    await tester.tap(settingsActionFinder.first);
    await tester.pumpAndSettle();

    // 6. Verify Settings Screen
    expect(find.text('Pengaturan'), findsOneWidget);
    expect(find.text('demo@fluttea.dev'), findsOneWidget);

    // 7. Scroll and Logout
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    final logoutButton = find.text('Keluar');
    expect(logoutButton, findsOneWidget);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    // 8. Verify redirected back to Login Screen
    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
