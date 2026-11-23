import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('id')];

  /// No description provided for @ok.
  ///
  /// In id, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get retry;

  /// No description provided for @searchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari...'**
  String get searchHint;

  /// No description provided for @loading.
  ///
  /// In id, this message translates to:
  /// **'Memuat data...'**
  String get loading;

  /// No description provided for @emptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Tidak Ada Data'**
  String get emptyTitle;

  /// No description provided for @emptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Data belum tersedia untuk saat ini.'**
  String get emptyMessage;

  /// No description provided for @errorTitle.
  ///
  /// In id, this message translates to:
  /// **'Terjadi Kesalahan'**
  String get errorTitle;

  /// No description provided for @errorGeneric.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kendala saat memuat data. Silakan coba lagi.'**
  String get errorGeneric;

  /// No description provided for @offlineMessage.
  ///
  /// In id, this message translates to:
  /// **'Koneksi internet terputus'**
  String get offlineMessage;

  /// No description provided for @privacyProtected.
  ///
  /// In id, this message translates to:
  /// **'Konten Terlindungi'**
  String get privacyProtected;

  /// No description provided for @splashTagline.
  ///
  /// In id, this message translates to:
  /// **'Template Flutter Ringkas, Aman & Tangguh'**
  String get splashTagline;

  /// No description provided for @authWelcomeTitle.
  ///
  /// In id, this message translates to:
  /// **'Selamat Datang'**
  String get authWelcomeTitle;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk melanjutkan ke {appName}'**
  String authWelcomeSubtitle(String appName);

  /// No description provided for @authLoginButton.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get authLoginButton;

  /// No description provided for @authLoginSuccess.
  ///
  /// In id, this message translates to:
  /// **'Login berhasil. Selamat datang!'**
  String get authLoginSuccess;

  /// No description provided for @authLoginFailed.
  ///
  /// In id, this message translates to:
  /// **'Autentikasi gagal. Periksa email dan password.'**
  String get authLoginFailed;

  /// No description provided for @authEmailLabel.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In id, this message translates to:
  /// **'user@example.com'**
  String get authEmailHint;

  /// No description provided for @authEmailRequired.
  ///
  /// In id, this message translates to:
  /// **'Email tidak boleh kosong'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In id, this message translates to:
  /// **'Format email tidak valid'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordLabel.
  ///
  /// In id, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In id, this message translates to:
  /// **'Minimal 6 karakter'**
  String get authPasswordHint;

  /// No description provided for @authPasswordRequired.
  ///
  /// In id, this message translates to:
  /// **'Password tidak boleh kosong'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In id, this message translates to:
  /// **'Password minimal 6 karakter'**
  String get authPasswordMinLength;

  /// No description provided for @authFillDemo.
  ///
  /// In id, this message translates to:
  /// **'Isi Kredensial Demo'**
  String get authFillDemo;

  /// No description provided for @authOpenDevTools.
  ///
  /// In id, this message translates to:
  /// **'Buka DevTools Langsung'**
  String get authOpenDevTools;

  /// No description provided for @homeGreeting.
  ///
  /// In id, this message translates to:
  /// **'Halo, {user}!'**
  String homeGreeting(String user);

  /// No description provided for @homeSettingsTooltip.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get homeSettingsTooltip;

  /// No description provided for @homeAppSettings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan Aplikasi'**
  String get homeAppSettings;

  /// No description provided for @homeOpenDevToolsHub.
  ///
  /// In id, this message translates to:
  /// **'Buka DevTools Hub'**
  String get homeOpenDevToolsHub;

  /// No description provided for @homeOpenUiGallery.
  ///
  /// In id, this message translates to:
  /// **'Buka UI Gallery'**
  String get homeOpenUiGallery;

  /// No description provided for @homeOpenStateExamples.
  ///
  /// In id, this message translates to:
  /// **'Buka State Examples'**
  String get homeOpenStateExamples;

  /// No description provided for @homeOpenNetworkExamples.
  ///
  /// In id, this message translates to:
  /// **'Buka Network & Mock Server'**
  String get homeOpenNetworkExamples;

  /// No description provided for @homeOpenSecurityShowcase.
  ///
  /// In id, this message translates to:
  /// **'Buka Security Showcase'**
  String get homeOpenSecurityShowcase;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// No description provided for @settingsAppearanceTitle.
  ///
  /// In id, this message translates to:
  /// **'Tampilan'**
  String get settingsAppearanceTitle;

  /// No description provided for @settingsAppearanceSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih preferensi tema aplikasi'**
  String get settingsAppearanceSubtitle;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In id, this message translates to:
  /// **'Sistem'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Bahasa antarmuka aplikasi'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsLanguageId.
  ///
  /// In id, this message translates to:
  /// **'Indonesia'**
  String get settingsLanguageId;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsSecurityTitle.
  ///
  /// In id, this message translates to:
  /// **'Keamanan & Notifikasi'**
  String get settingsSecurityTitle;

  /// No description provided for @settingsSecuritySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kelola preferensi privasi dan pemberitahuan'**
  String get settingsSecuritySubtitle;

  /// No description provided for @settingsBiometricsTitle.
  ///
  /// In id, this message translates to:
  /// **'Biometrik'**
  String get settingsBiometricsTitle;

  /// No description provided for @settingsBiometricsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk cepat dengan sidik jari atau Face ID'**
  String get settingsBiometricsSubtitle;

  /// No description provided for @settingsNotificationsTitle.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get settingsNotificationsTitle;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Terima pembaruan penting dan peringatan'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsAccountTitle.
  ///
  /// In id, this message translates to:
  /// **'Akun & Sesi'**
  String get settingsAccountTitle;

  /// No description provided for @settingsAccountSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Informasi akun yang sedang aktif'**
  String get settingsAccountSubtitle;

  /// No description provided for @settingsUserFallback.
  ///
  /// In id, this message translates to:
  /// **'Pengguna {userId}'**
  String settingsUserFallback(String userId);

  /// No description provided for @settingsUserIdLabel.
  ///
  /// In id, this message translates to:
  /// **'ID: {userId}'**
  String settingsUserIdLabel(String userId);

  /// No description provided for @settingsLogoutButton.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get settingsLogoutButton;

  /// No description provided for @settingsLogoutSuccess.
  ///
  /// In id, this message translates to:
  /// **'Berhasil keluar'**
  String get settingsLogoutSuccess;

  /// No description provided for @settingsNotLoggedIn.
  ///
  /// In id, this message translates to:
  /// **'Anda belum masuk ke akun.'**
  String get settingsNotLoggedIn;

  /// No description provided for @settingsDeveloperTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengembang'**
  String get settingsDeveloperTitle;

  /// No description provided for @settingsDeveloperSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Fitur pengujian dan utilitas internal ({envName})'**
  String settingsDeveloperSubtitle(String envName);

  /// No description provided for @settingsOpenDevToolsHub.
  ///
  /// In id, this message translates to:
  /// **'Buka DevTools Hub'**
  String get settingsOpenDevToolsHub;

  /// No description provided for @settingsOpenUiGallery.
  ///
  /// In id, this message translates to:
  /// **'Komponen UI Gallery'**
  String get settingsOpenUiGallery;

  /// No description provided for @templateTitle.
  ///
  /// In id, this message translates to:
  /// **'Fitur Template'**
  String get templateTitle;

  /// No description provided for @templateEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Data'**
  String get templateEmptyTitle;

  /// No description provided for @templateEmptyMessage.
  ///
  /// In id, this message translates to:
  /// **'Data template belum dimuat.'**
  String get templateEmptyMessage;

  /// No description provided for @devToolsTitle.
  ///
  /// In id, this message translates to:
  /// **'Fluttea DevTools'**
  String get devToolsTitle;

  /// No description provided for @devToolsDisabledTitle.
  ///
  /// In id, this message translates to:
  /// **'DevTools Dinonaktifkan'**
  String get devToolsDisabledTitle;

  /// No description provided for @devToolsDisabledMessage.
  ///
  /// In id, this message translates to:
  /// **'DevTools dinonaktifkan di environment production.'**
  String get devToolsDisabledMessage;

  /// No description provided for @devToolsTabEnv.
  ///
  /// In id, this message translates to:
  /// **'Env'**
  String get devToolsTabEnv;

  /// No description provided for @devToolsTabNetwork.
  ///
  /// In id, this message translates to:
  /// **'Network'**
  String get devToolsTabNetwork;

  /// No description provided for @devToolsTabStorage.
  ///
  /// In id, this message translates to:
  /// **'Storage'**
  String get devToolsTabStorage;

  /// No description provided for @devToolsTabLog.
  ///
  /// In id, this message translates to:
  /// **'Log'**
  String get devToolsTabLog;

  /// No description provided for @devToolsTabSecurity.
  ///
  /// In id, this message translates to:
  /// **'Security'**
  String get devToolsTabSecurity;

  /// No description provided for @devToolsTabState.
  ///
  /// In id, this message translates to:
  /// **'State'**
  String get devToolsTabState;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
