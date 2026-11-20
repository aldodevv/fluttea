import 'dart:async';

import 'package:fluttea/app/providers.dart';
import 'package:fluttea/features/settings/data/settings_repository.dart';
import 'package:fluttea/features/settings/domain/models/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final storage = ref.watch(preferencesStorageProvider);
  return SettingsRepositoryImpl(storage);
});

class SettingsNotifier extends Notifier<AppSettings> {
  bool _hydrated = false;

  @override
  AppSettings build() {
    _hydrated = false;
    unawaited(_hydrate());
    return const AppSettings();
  }

  Future<void> _hydrate() async {
    final repo = ref.read(settingsRepositoryProvider);
    final settings = await repo.loadSettings();
    if (!_hydrated) {
      _hydrated = true;
      state = settings;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _hydrated = true;
    state = state.copyWith(themeMode: mode);
    final repo = ref.read(settingsRepositoryProvider);
    await repo.saveThemeMode(mode);
  }

  Future<void> setLocale(Locale locale) async {
    _hydrated = true;
    state = state.copyWith(locale: locale);
    final repo = ref.read(settingsRepositoryProvider);
    await repo.saveLocale(locale);
  }

  Future<void> setBiometrics(bool enabled) async {
    _hydrated = true;
    state = state.copyWith(biometricsEnabled: enabled);
    final repo = ref.read(settingsRepositoryProvider);
    await repo.saveBiometricsEnabled(enabled);
  }

  Future<void> setNotifications(bool enabled) async {
    _hydrated = true;
    state = state.copyWith(notificationsEnabled: enabled);
    final repo = ref.read(settingsRepositoryProvider);
    await repo.saveNotificationsEnabled(enabled);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
