import 'package:fluttea/core/l10n/app_localizations.dart';
import 'package:fluttea/core/theme/extensions/app_spacing_theme.dart';
import 'package:fluttea/core/theme/extensions/app_status_colors.dart';
import 'package:material_ui/material_ui.dart';

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  TextTheme get text => textTheme;

  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      AppLocalizationsDelegates.fallback;

  AppStatusColors get statusColors => theme.extension<AppStatusColors>() ?? AppStatusColors.light;

  AppSpacingTheme get spacing => theme.extension<AppSpacingTheme>() ?? AppSpacingTheme.regular;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  EdgeInsets get screenPadding => MediaQuery.paddingOf(this);

  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  bool get isDarkMode => theme.brightness == Brightness.dark;

  void unfocusKeyboard() {
    FocusScope.of(this).unfocus();
  }
}
