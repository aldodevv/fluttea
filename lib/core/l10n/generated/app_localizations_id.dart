// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Batal';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get searchHint => 'Cari...';

  @override
  String get loading => 'Memuat data...';

  @override
  String get emptyTitle => 'Tidak Ada Data';

  @override
  String get emptyMessage => 'Data belum tersedia untuk saat ini.';

  @override
  String get errorTitle => 'Terjadi Kesalahan';

  @override
  String get errorGeneric => 'Terjadi kendala saat memuat data. Silakan coba lagi.';

  @override
  String get offlineMessage => 'Koneksi internet terputus';

  @override
  String get privacyProtected => 'Konten Terlindungi';

  @override
  String get splashTagline => 'Template Flutter Ringkas, Aman & Tangguh';

  @override
  String get authWelcomeTitle => 'Selamat Datang';

  @override
  String authWelcomeSubtitle(String appName) {
    return 'Masuk untuk melanjutkan ke $appName';
  }

  @override
  String get authLoginButton => 'Masuk';

  @override
  String get authLoginSuccess => 'Login berhasil. Selamat datang!';

  @override
  String get authLoginFailed => 'Autentikasi gagal. Periksa email dan password.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'user@example.com';

  @override
  String get authEmailRequired => 'Email tidak boleh kosong';

  @override
  String get authEmailInvalid => 'Format email tidak valid';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => 'Minimal 6 karakter';

  @override
  String get authPasswordRequired => 'Password tidak boleh kosong';

  @override
  String get authPasswordMinLength => 'Password minimal 6 karakter';

  @override
  String get authFillDemo => 'Isi Kredensial Demo';

  @override
  String get authOpenDevTools => 'Buka DevTools Langsung';

  @override
  String homeGreeting(String user) {
    return 'Halo, $user!';
  }

  @override
  String get homeSettingsTooltip => 'Pengaturan';

  @override
  String get homeAppSettings => 'Pengaturan Aplikasi';

  @override
  String get homeOpenDevToolsHub => 'Buka DevTools Hub';

  @override
  String get homeOpenUiGallery => 'Buka UI Gallery';

  @override
  String get homeOpenStateExamples => 'Buka State Examples';

  @override
  String get homeOpenNetworkExamples => 'Buka Network & Mock Server';

  @override
  String get homeOpenSecurityShowcase => 'Buka Security Showcase';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsAppearanceTitle => 'Tampilan';

  @override
  String get settingsAppearanceSubtitle => 'Pilih preferensi tema aplikasi';

  @override
  String get settingsThemeSystem => 'Sistem';

  @override
  String get settingsThemeLight => 'Terang';

  @override
  String get settingsThemeDark => 'Gelap';

  @override
  String get settingsLanguageTitle => 'Bahasa';

  @override
  String get settingsLanguageSubtitle => 'Bahasa antarmuka aplikasi';

  @override
  String get settingsLanguageId => 'Indonesia';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsSecurityTitle => 'Keamanan & Notifikasi';

  @override
  String get settingsSecuritySubtitle => 'Kelola preferensi privasi dan pemberitahuan';

  @override
  String get settingsBiometricsTitle => 'Biometrik';

  @override
  String get settingsBiometricsSubtitle => 'Masuk cepat dengan sidik jari atau Face ID';

  @override
  String get settingsNotificationsTitle => 'Notifikasi';

  @override
  String get settingsNotificationsSubtitle => 'Terima pembaruan penting dan peringatan';

  @override
  String get settingsAccountTitle => 'Akun & Sesi';

  @override
  String get settingsAccountSubtitle => 'Informasi akun yang sedang aktif';

  @override
  String settingsUserFallback(String userId) {
    return 'Pengguna $userId';
  }

  @override
  String settingsUserIdLabel(String userId) {
    return 'ID: $userId';
  }

  @override
  String get settingsLogoutButton => 'Keluar';

  @override
  String get settingsLogoutSuccess => 'Berhasil keluar';

  @override
  String get settingsNotLoggedIn => 'Anda belum masuk ke akun.';

  @override
  String get settingsDeveloperTitle => 'Pengembang';

  @override
  String settingsDeveloperSubtitle(String envName) {
    return 'Fitur pengujian dan utilitas internal ($envName)';
  }

  @override
  String get settingsOpenDevToolsHub => 'Buka DevTools Hub';

  @override
  String get settingsOpenUiGallery => 'Komponen UI Gallery';

  @override
  String get templateTitle => 'Fitur Template';

  @override
  String get templateEmptyTitle => 'Belum Ada Data';

  @override
  String get templateEmptyMessage => 'Data template belum dimuat.';

  @override
  String get devToolsTitle => 'Fluttea DevTools';

  @override
  String get devToolsDisabledTitle => 'DevTools Dinonaktifkan';

  @override
  String get devToolsDisabledMessage => 'DevTools dinonaktifkan di environment production.';

  @override
  String get devToolsTabEnv => 'Env';

  @override
  String get devToolsTabNetwork => 'Network';

  @override
  String get devToolsTabStorage => 'Storage';

  @override
  String get devToolsTabLog => 'Log';

  @override
  String get devToolsTabSecurity => 'Security';

  @override
  String get devToolsTabState => 'State';
}
