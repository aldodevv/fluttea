import 'package:fluttea/app/flavor.dart';
import 'package:fluttea/app/providers.dart';
import 'package:fluttea/core/state/session_state_provider.dart';
import 'package:fluttea/core/storage/prefs/preferences_storage.dart';
import 'package:fluttea/features/settings/data/settings_repository.dart';
import 'package:fluttea/features/settings/presentation/screens/settings_screen.dart';
import 'package:fluttea/features/settings/state/settings_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _InMemoryPreferencesStorage extends PreferencesStorage {
  final Map<String, dynamic> _map = {};

  @override
  Future<String?> getString(String key) async => _map[key] as String?;

  @override
  Future<void> setString(String key, String value) async {
    _map[key] = value;
  }

  @override
  Future<bool?> getBool(String key) async => _map[key] as bool?;

  @override
  Future<void> setBool(String key, bool value) async {
    _map[key] = value;
  }

  @override
  Future<Set<String>> getKeys() async => _map.keys.toSet();
}

class _AuthSessionNotifier extends SessionNotifier {
  @override
  SessionState build() => const SessionState.authenticated(
    userId: 'usr_settings_test',
    token: 'tok_settings',
    email: 'tester@fluttea.dev',
  );
}

void main() {
  group('SettingsRepository', () {
    late _InMemoryPreferencesStorage fakeStorage;
    late SettingsRepository repository;

    setUp(() {
      fakeStorage = _InMemoryPreferencesStorage();
      repository = SettingsRepositoryImpl(fakeStorage);
    });

    test('loadSettings returns defaults when storage is empty', () async {
      final settings = await repository.loadSettings();
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.locale.languageCode, 'id');
      expect(settings.biometricsEnabled, isFalse);
      expect(settings.notificationsEnabled, isTrue);
    });

    test('saveThemeMode, saveLocale, saveBiometrics, saveNotifications persist values', () async {
      await repository.saveThemeMode(ThemeMode.dark);
      await repository.saveLocale(const Locale('en'));
      await repository.saveBiometricsEnabled(true);
      await repository.saveNotificationsEnabled(false);

      final loaded = await repository.loadSettings();
      expect(loaded.themeMode, ThemeMode.dark);
      expect(loaded.locale.languageCode, 'en');
      expect(loaded.biometricsEnabled, isTrue);
      expect(loaded.notificationsEnabled, isFalse);
    });
  });

  group('SettingsNotifier', () {
    test('updates state and persists changes', () async {
      final fakeStorage = _InMemoryPreferencesStorage();
      final container = ProviderContainer(
        overrides: [preferencesStorageProvider.overrideWithValue(fakeStorage)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(settingsProvider.notifier);
      await notifier.setThemeMode(ThemeMode.light);
      await notifier.setLocale(const Locale('en'));
      await notifier.setBiometrics(true);
      await notifier.setNotifications(false);

      final current = container.read(settingsProvider);
      expect(current.themeMode, ThemeMode.light);
      expect(current.locale.languageCode, 'en');
      expect(current.biometricsEnabled, isTrue);
      expect(current.notificationsEnabled, isFalse);
    });
  });

  group('SettingsScreen UI', () {
    testWidgets('renders all sections and responds to interactions', (tester) async {
      final fakeStorage = _InMemoryPreferencesStorage();
      final env = AppEnv.of(AppFlavor.dev);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appEnvProvider.overrideWithValue(env),
            preferencesStorageProvider.overrideWithValue(fakeStorage),
            sessionProvider.overrideWith(_AuthSessionNotifier.new),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify sections
      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('Tampilan'), findsOneWidget);
      expect(find.text('Bahasa'), findsOneWidget);
      expect(find.text('Keamanan & Notifikasi'), findsOneWidget);
      expect(find.text('Akun & Sesi'), findsOneWidget);
      expect(find.text('tester@fluttea.dev'), findsOneWidget);
      expect(find.text('Keluar'), findsOneWidget);

      // Tap dark mode
      await tester.tap(find.text('Gelap'));
      await tester.pumpAndSettle();

      // Tap English
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Toggle biometric switch
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      // Scroll down and Tap Keluar
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();
    });
  });
}
