import 'package:fluttea/core/theme/color_scheme.dart';
import 'package:fluttea/core/theme/component_themes/appbar_theme.dart';
import 'package:fluttea/core/theme/component_themes/bottom_sheet_theme.dart';
import 'package:fluttea/core/theme/component_themes/button_theme.dart';
import 'package:fluttea/core/theme/component_themes/card_theme.dart';
import 'package:fluttea/core/theme/component_themes/dialog_theme.dart';
import 'package:fluttea/core/theme/component_themes/input_theme.dart';
import 'package:fluttea/core/theme/extensions/app_spacing_theme.dart';
import 'package:fluttea/core/theme/extensions/app_status_colors.dart';
import 'package:fluttea/core/theme/text_theme.dart';
import 'package:material_ui/material_ui.dart';

abstract final class AppTheme {
  static ThemeData light() =>
      _build(colors: AppColorScheme.light(), statusColors: AppStatusColors.light);

  static ThemeData dark() =>
      _build(colors: AppColorScheme.dark(), statusColors: AppStatusColors.dark);

  static ThemeData _build({required ColorScheme colors, required AppStatusColors statusColors}) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      textTheme: AppTextTheme.build(colors),
      appBarTheme: AppAppBarTheme.build(colors),
      elevatedButtonTheme: AppButtonTheme.elevated(colors),
      filledButtonTheme: AppButtonTheme.filled(colors),
      outlinedButtonTheme: AppButtonTheme.outlined(colors),
      textButtonTheme: AppButtonTheme.text(colors),
      inputDecorationTheme: AppInputTheme.build(colors),
      cardTheme: AppCardTheme.build(colors),
      dialogTheme: AppDialogTheme.build(colors),
      bottomSheetTheme: AppBottomSheetTheme.build(colors),
      extensions: [statusColors, AppSpacingTheme.regular],
    );
  }
}
