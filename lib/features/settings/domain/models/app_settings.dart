import 'package:material_ui/material_ui.dart';

@immutable
final class AppSettings {
  const new({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('id'),
    this.biometricsEnabled = false,
    this.notificationsEnabled = true,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final bool biometricsEnabled;
  final bool notificationsEnabled;

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? biometricsEnabled,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.locale == locale &&
        other.biometricsEnabled == biometricsEnabled &&
        other.notificationsEnabled == notificationsEnabled;
  }

  @override
  int get hashCode => Object.hash(themeMode, locale, biometricsEnabled, notificationsEnabled);

  @override
  String toString() =>
      'AppSettings(themeMode: $themeMode, locale: ${locale.languageCode}, '
      'biometrics: $biometricsEnabled, notifications: $notificationsEnabled)';
}
