import 'package:fluttea/core/constants/ui/radii.dart';
import 'package:material_ui/material_ui.dart';

abstract final class AppDialogTheme {
  static DialogThemeData build(ColorScheme colors) {
    return DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
      backgroundColor: colors.surface,
      surfaceTintColor: colors.surfaceTint,
    );
  }
}
