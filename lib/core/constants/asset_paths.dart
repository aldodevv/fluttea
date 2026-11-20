abstract final class AssetPaths {
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _l10n = 'assets/l10n';

  static const String appLogo = '$_images/logo.png';
  static const String splashLogo = '$_images/splash.png';
  static const String placeholder = '$_images/placeholder.png';

  static const String icBack = '$_icons/ic_back.svg';
  static const String icClose = '$_icons/ic_close.svg';

  static String l10n(String languageCode) => '$_l10n/$languageCode.json';
}
