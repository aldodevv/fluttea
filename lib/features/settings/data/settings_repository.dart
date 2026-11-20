import 'package:fluttea/core/storage/prefs/preferences_storage.dart';
import 'package:fluttea/features/settings/domain/models/app_settings.dart';
import 'package:material_ui/material_ui.dart';

abstract interface class SettingsRepository {
  Future<AppSettings> loadSettings();
  Future<void> saveThemeMode(ThemeMode themeMode);
  Future<void> saveLocale(Locale locale);
  Future<void> saveBiometricsEnabled(bool enabled);
  Future<void> saveNotificationsEnabled(bool enabled);
}

final class SettingsRepositoryImpl implements SettingsRepository {
  const new(this._storage);

  final PreferencesStorage _storage;

  static const String _keyThemeMode = 'setting_theme_mode';
  static const String _keyLocale = 'setting_locale';
  static const String _keyBiometrics = 'setting_biometrics';
  static const String _keyNotifications = 'setting_notifications';

  @override
  Future<AppSettings> loadSettings() async {
    final themeStr = await _storage.getString(_keyThemeMode);
    final localeStr = await _storage.getString(_keyLocale);
    final biometrics = await _storage.getBool(_keyBiometrics);
    final notifications = await _storage.getBool(_keyNotifications);

    final themeMode = switch (themeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final locale = switch (localeStr) {
      'en' => const Locale('en'),
      _ => const Locale('id'),
    };

    return AppSettings(
      themeMode: themeMode,
      locale: locale,
      biometricsEnabled: biometrics ?? false,
      notificationsEnabled: notifications ?? true,
    );
  }

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final str = switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _storage.setString(_keyThemeMode, str);
  }

  @override
  Future<void> saveLocale(Locale locale) async {
    await _storage.setString(_keyLocale, locale.languageCode);
  }

  @override
  Future<void> saveBiometricsEnabled(bool enabled) async {
    await _storage.setBool(_keyBiometrics, enabled);
  }

  @override
  Future<void> saveNotificationsEnabled(bool enabled) async {
    await _storage.setBool(_keyNotifications, enabled);
  }
}
