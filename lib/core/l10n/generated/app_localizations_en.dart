// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get searchHint => 'Search...';

  @override
  String get loading => 'Loading data...';

  @override
  String get emptyTitle => 'No Data';

  @override
  String get emptyMessage => 'No data is available at the moment.';

  @override
  String get errorTitle => 'Something Went Wrong';

  @override
  String get errorGeneric => 'An error occurred while loading data. Please try again.';

  @override
  String get offlineMessage => 'No internet connection';

  @override
  String get privacyProtected => 'Protected Content';

  @override
  String get splashTagline => 'Compact, Secure & Resilient Flutter Template';

  @override
  String get authWelcomeTitle => 'Welcome';

  @override
  String authWelcomeSubtitle(String appName) {
    return 'Sign in to continue to $appName';
  }

  @override
  String get authLoginButton => 'Sign In';

  @override
  String get authLoginSuccess => 'Signed in successfully. Welcome!';

  @override
  String get authLoginFailed => 'Authentication failed. Check your email and password.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'user@example.com';

  @override
  String get authEmailRequired => 'Email cannot be empty';

  @override
  String get authEmailInvalid => 'Invalid email format';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => 'Minimum 6 characters';

  @override
  String get authPasswordRequired => 'Password cannot be empty';

  @override
  String get authPasswordMinLength => 'Password must be at least 6 characters';

  @override
  String get authFillDemo => 'Fill Demo Credentials';

  @override
  String get authOpenDevTools => 'Open DevTools Directly';

  @override
  String homeGreeting(String user) {
    return 'Hello, $user!';
  }

  @override
  String get homeSettingsTooltip => 'Settings';

  @override
  String get homeAppSettings => 'App Settings';

  @override
  String get homeOpenDevToolsHub => 'Open DevTools Hub';

  @override
  String get homeOpenUiGallery => 'Open UI Gallery';

  @override
  String get homeOpenStateExamples => 'Open State Examples';

  @override
  String get homeOpenNetworkExamples => 'Open Network & Mock Server';

  @override
  String get homeOpenSecurityShowcase => 'Open Security Showcase';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearanceTitle => 'Appearance';

  @override
  String get settingsAppearanceSubtitle => 'Choose your preferred app theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Application interface language';

  @override
  String get settingsLanguageId => 'Indonesia';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsSecurityTitle => 'Security & Notifications';

  @override
  String get settingsSecuritySubtitle => 'Manage privacy and notification preferences';

  @override
  String get settingsBiometricsTitle => 'Biometrics';

  @override
  String get settingsBiometricsSubtitle => 'Quick sign-in with fingerprint or Face ID';

  @override
  String get settingsNotificationsTitle => 'Notifications';

  @override
  String get settingsNotificationsSubtitle => 'Receive important updates and alerts';

  @override
  String get settingsAccountTitle => 'Account & Session';

  @override
  String get settingsAccountSubtitle => 'Currently active account information';

  @override
  String settingsUserFallback(String userId) {
    return 'User $userId';
  }

  @override
  String settingsUserIdLabel(String userId) {
    return 'ID: $userId';
  }

  @override
  String get settingsLogoutButton => 'Sign Out';

  @override
  String get settingsLogoutSuccess => 'Signed out successfully';

  @override
  String get settingsNotLoggedIn => 'You are not signed in.';

  @override
  String get settingsDeveloperTitle => 'Developer';

  @override
  String settingsDeveloperSubtitle(String envName) {
    return 'Testing features and internal utilities ($envName)';
  }

  @override
  String get settingsOpenDevToolsHub => 'Open DevTools Hub';

  @override
  String get settingsOpenUiGallery => 'UI Component Gallery';

  @override
  String get templateTitle => 'Template Feature';

  @override
  String get templateEmptyTitle => 'No Data Yet';

  @override
  String get templateEmptyMessage => 'Template data has not been loaded.';

  @override
  String get devToolsTitle => 'Fluttea DevTools';

  @override
  String get devToolsDisabledTitle => 'DevTools Disabled';

  @override
  String get devToolsDisabledMessage => 'DevTools is disabled in production environment.';

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
