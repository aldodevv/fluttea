import 'package:fluttea/core/constants/ui/elevations.dart';
import 'package:fluttea/core/constants/ui/radii.dart';
import 'package:material_ui/material_ui.dart';

abstract final class AppCardTheme {
  static CardThemeData build(ColorScheme colors) {
    return CardThemeData(
      elevation: Elevations.level1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.md),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
    );
  }
}
