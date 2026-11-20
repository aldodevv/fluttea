import 'package:fluttea/app/flavor.dart';
import 'package:fluttea/app/providers.dart';
import 'package:fluttea/core/errors/failure.dart';
import 'package:fluttea/core/errors/result.dart';
import 'package:fluttea/core/state/session_state_provider.dart';
import 'package:fluttea/core/storage/secure/secure_storage.dart';
import 'package:fluttea/features/auth/data/auth_api.dart';
import 'package:fluttea/features/auth/data/auth_repository.dart';
import 'package:fluttea/features/auth/data/dto/login_request_dto.dart';
import 'package:fluttea/features/auth/data/dto/login_response_dto.dart';
import 'package:fluttea/features/auth/domain/models/user.dart';
import 'package:fluttea/features/auth/presentation/screens/login_screen.dart';
import 'package:fluttea/features/auth/presentation/widgets/login_form.dart';
import 'package:fluttea/features/auth/state/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _FakeAuthApi implements AuthApi {
  bool shouldSucceed = true;
  String? lastTokenLoggedOut;

  @override
  Future<Result<LoginResponseDto>> login(LoginRequestDto request) async {
    if (!shouldSucceed || request.password == 'wrong') {
      return const Result.err(AuthFailure(message: 'Email atau password salah'));
    }
    return Result.ok(
      LoginResponseDto(
        token: 'token_mock_123',
        userId: 'usr_456',
        name: 'Aldo Developer',
        email: request.email,
        role: 'admin',
      ),
    );
  }

  @override
  Future<Result<void>> logout(String token) async {
    lastTokenLoggedOut = token;
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
  group('AuthRepository', () {
    late _FakeAuthApi fakeApi;
    late _InMemorySecureStorage fakeStorage;
    late AuthRepository repository;

    setUp(() {
      fakeApi = _FakeAuthApi();
      fakeStorage = _InMemorySecureStorage();
      repository = AuthRepositoryImpl(fakeApi, fakeStorage);
    });

    test('login success stores credentials and returns User domain model', () async {
      final result = await repository.login(email: 'dev@fluttea.com', password: 'password123');

      expect(result, isA<Ok<User>>());
      final user = (result as Ok<User>).value;
      expect(user.id, 'usr_456');
      expect(user.email, 'dev@fluttea.com');
      expect(user.role, 'admin');

      expect(await fakeStorage.read('auth_token'), 'token_mock_123');
      expect(await fakeStorage.read('auth_user_id'), 'usr_456');
    });

    test('login error returns Failure and does not persist credentials', () async {
      fakeApi.shouldSucceed = false;
      final result = await repository.login(email: 'dev@fluttea.com', password: 'wrong');

      expect(result, isA<Err<User>>());
      expect((result as Err<User>).failure, isA<AuthFailure>());
      expect(await fakeStorage.read('auth_token'), isNull);
    });

    test('logout clears secure storage and notifies API', () async {
      await fakeStorage.write('auth_token', 'token_active');
      await fakeStorage.write('auth_user_id', 'usr_active');

      final result = await repository.logout();
      expect(result, isA<Ok<void>>());
      expect(await fakeStorage.read('auth_token'), isNull);
      expect(await fakeStorage.read('auth_user_id'), isNull);
      expect(fakeApi.lastTokenLoggedOut, 'token_active');
    });

    test('restoreSession restores User when token & userId exist', () async {
      await fakeStorage.write('auth_token', 'tok_restored');
      await fakeStorage.write('auth_user_id', 'usr_restored');
      await fakeStorage.write('auth_user_name', 'Restored User');
      await fakeStorage.write('auth_user_email', 'restored@fluttea.dev');

      final result = await repository.restoreSession();
      expect(result, isA<Ok<User?>>());
      final user = (result as Ok<User?>).value;
      expect(user, isNotNull);
      expect(user!.id, 'usr_restored');
      expect(user.name, 'Restored User');
    });

    test('restoreSession returns null when storage is empty', () async {
      final result = await repository.restoreSession();
      expect(result, isA<Ok<User?>>());
      expect((result as Ok<User?>).value, isNull);
    });
  });

  group('AuthNotifier & Riverpod state', () {
    test('login triggers sessionProvider update', () async {
      final fakeApi = _FakeAuthApi();
      final fakeStorage = _InMemorySecureStorage();
      final container = ProviderContainer(
        overrides: [
          authApiProvider.overrideWithValue(fakeApi),
          secureStorageProvider.overrideWithValue(fakeStorage),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(sessionProvider).isAuthenticated, isFalse);

      final notifier = container.read(authNotifierProvider.notifier);
      final success = await notifier.login(email: 'dev@fluttea.dev', password: 'password123');

      expect(success, isTrue);
      expect(container.read(sessionProvider).isAuthenticated, isTrue);
      final session = container.read(sessionProvider) as AuthenticatedSession;
      expect(session.userId, 'usr_456');

      // Logout
      await notifier.logout();
      expect(container.read(sessionProvider).isAuthenticated, isFalse);
    });
  });

  group('LoginForm & LoginScreen UI', () {
    testWidgets('validation prevents submit on empty fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: LoginForm())),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Email tidak boleh kosong'), findsOneWidget);
      expect(find.text('Password tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('tap Isi Kredensial Demo fills valid credentials', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: LoginForm())),
        ),
      );

      await tester.tap(find.text('Isi Kredensial Demo'));
      await tester.pumpAndSettle();

      expect(find.text('demo@fluttea.dev'), findsOneWidget);
    });

    testWidgets('LoginScreen renders header, demo button and DevTools shortcut in dev', (
      tester,
    ) async {
      final env = AppEnv.of(AppFlavor.dev);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appEnvProvider.overrideWithValue(env)],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      expect(find.text('Selamat Datang'), findsOneWidget);
      expect(find.text('Buka DevTools Langsung'), findsOneWidget);
    });
  });
}
