import 'dart:convert';

import 'package:fluttea/core/constants/app/locale_codes.dart';
import 'package:fluttea/core/constants/asset_paths.dart';
import 'package:fluttea/core/l10n/app_localizations_fallback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

class AppLocalizations {
  const new(this.locale, this._strings);

  final Locale locale;
  final Map<String, dynamic> _strings;

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    ...GlobalMaterialLocalizations.delegates,
  ];

  static const List<Locale> supportedLocales = [Locale(LocaleCodes.id), Locale(LocaleCodes.en)];

  static const AppLocalizations _defaultFallback = AppLocalizations(
    Locale(LocaleCodes.defaultLocale),
    defaultIdL10nMap,
  );

  static final Map<String, Map<String, dynamic>> _cache = {
    LocaleCodes.defaultLocale: defaultIdL10nMap,
  };

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ?? _defaultFallback;

  static Future<AppLocalizations> load(Locale locale) {
    final code = supportedLocales.any((l) => l.languageCode == locale.languageCode)
        ? locale.languageCode
        : LocaleCodes.defaultLocale;
    final cached = _cache[code];
    if (cached != null) {
      return SynchronousFuture(AppLocalizations(Locale(code), cached));
    }
    return _loadFromAsset(code);
  }

  static Future<AppLocalizations> _loadFromAsset(String code) async {
    final jsonString = await rootBundle.loadString(AssetPaths.l10n(code));
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    _cache[code] = decoded;
    return AppLocalizations(Locale(code), decoded);
  }

  String translate(String key, [Map<String, String>? params]) {
    final parts = key.split('.');
    dynamic current = _strings;
    for (final part in parts) {
      if (current is Map<String, dynamic> && current.containsKey(part)) {
        current = current[part];
      } else {
        current = null;
        break;
      }
    }

    var value = current is String ? current : key;
    if (params != null) {
      for (final entry in params.entries) {
        value = value.replaceAll('{${entry.key}}', entry.value);
      }
    }
    return value;
  }

  // Common
  String get ok => translate('common.ok');
  String get cancel => translate('common.cancel');
  String get retry => translate('common.retry');
  String get searchHint => translate('common.searchHint');
  String get loading => translate('common.loading');
  String get emptyTitle => translate('common.emptyTitle');
  String get emptyMessage => translate('common.emptyMessage');
  String get errorTitle => translate('common.errorTitle');
  String get errorGeneric => translate('common.errorGeneric');
  String get offlineMessage => translate('common.offlineMessage');
  String get privacyProtected => translate('common.privacyProtected');

  // Splash
  String get splashTagline => translate('splash.tagline');

  // Auth
  String get authWelcomeTitle => translate('auth.welcomeTitle');
  String authWelcomeSubtitle(String appName) =>
      translate('auth.welcomeSubtitle', {'appName': appName});
  String get authLoginButton => translate('auth.loginButton');
  String get authLoginSuccess => translate('auth.loginSuccess');
  String get authLoginFailed => translate('auth.loginFailed');
  String get authEmailLabel => translate('auth.emailLabel');
  String get authEmailHint => translate('auth.emailHint');
  String get authEmailRequired => translate('auth.emailRequired');
  String get authEmailInvalid => translate('auth.emailInvalid');
  String get authPasswordLabel => translate('auth.passwordLabel');
  String get authPasswordHint => translate('auth.passwordHint');
  String get authPasswordRequired => translate('auth.passwordRequired');
  String get authPasswordMinLength => translate('auth.passwordMinLength');
  String get authFillDemo => translate('auth.fillDemo');
  String get authOpenDevTools => translate('auth.openDevTools');

  // Home
  String homeGreeting(String user) => translate('home.greeting', {'user': user});
  String get homeSettingsTooltip => translate('home.settingsTooltip');
  String get homeAppSettings => translate('home.appSettings');
  String get homeOpenDevToolsHub => translate('home.openDevToolsHub');
  String get homeOpenUiGallery => translate('home.openUiGallery');
  String get homeOpenStateExamples => translate('home.openStateExamples');
  String get homeOpenNetworkExamples => translate('home.openNetworkExamples');
  String get homeOpenSecurityShowcase => translate('home.openSecurityShowcase');

  // Settings
  String get settingsTitle => translate('settings.title');
  String get settingsAppearanceTitle => translate('settings.appearanceTitle');
  String get settingsAppearanceSubtitle => translate('settings.appearanceSubtitle');
  String get settingsThemeSystem => translate('settings.themeSystem');
  String get settingsThemeLight => translate('settings.themeLight');
  String get settingsThemeDark => translate('settings.themeDark');
  String get settingsLanguageTitle => translate('settings.languageTitle');
  String get settingsLanguageSubtitle => translate('settings.languageSubtitle');
  String get settingsLanguageId => translate('settings.languageId');
  String get settingsLanguageEn => translate('settings.languageEn');
  String get settingsSecurityTitle => translate('settings.securityTitle');
  String get settingsSecuritySubtitle => translate('settings.securitySubtitle');
  String get settingsBiometricsTitle => translate('settings.biometricsTitle');
  String get settingsBiometricsSubtitle => translate('settings.biometricsSubtitle');
  String get settingsNotificationsTitle => translate('settings.notificationsTitle');
  String get settingsNotificationsSubtitle => translate('settings.notificationsSubtitle');
  String get settingsAccountTitle => translate('settings.accountTitle');
  String get settingsAccountSubtitle => translate('settings.accountSubtitle');
  String settingsUserFallback(String userId) =>
      translate('settings.userFallback', {'userId': userId});
  String settingsUserIdLabel(String userId) =>
      translate('settings.userIdLabel', {'userId': userId});
  String get settingsLogoutButton => translate('settings.logoutButton');
  String get settingsLogoutSuccess => translate('settings.logoutSuccess');
  String get settingsNotLoggedIn => translate('settings.notLoggedIn');
  String get settingsDeveloperTitle => translate('settings.developerTitle');
  String settingsDeveloperSubtitle(String envName) =>
      translate('settings.developerSubtitle', {'envName': envName});
  String get settingsOpenDevToolsHub => translate('settings.openDevToolsHub');
  String get settingsOpenUiGallery => translate('settings.openUiGallery');

  // Template
  String get templateTitle => translate('template.title');
  String get templateEmptyTitle => translate('template.emptyTitle');
  String get templateEmptyMessage => translate('template.emptyMessage');

  // DevTools
  String get devToolsTitle => translate('devtools.title');
  String get devToolsDisabledTitle => translate('devtools.disabledTitle');
  String get devToolsDisabledMessage => translate('devtools.disabledMessage');
  String get devToolsTabEnv => translate('devtools.tabEnv');
  String get devToolsTabNetwork => translate('devtools.tabNetwork');
  String get devToolsTabStorage => translate('devtools.tabStorage');
  String get devToolsTabLog => translate('devtools.tabLog');
  String get devToolsTabSecurity => translate('devtools.tabSecurity');
  String get devToolsTabState => translate('devtools.tabState');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const new();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
