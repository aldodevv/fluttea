import 'package:fluttea/core/l10n/generated/app_localizations.dart';
import 'package:fluttea/core/l10n/generated/app_localizations_id.dart';
import 'package:material_ui/material_ui.dart';

export 'package:fluttea/core/l10n/generated/app_localizations.dart';

abstract final class AppLocalizationsDelegates {
  static final AppLocalizations fallback = AppLocalizationsId();

  static const List<LocalizationsDelegate<dynamic>> delegates = [
    AppLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ];
}
