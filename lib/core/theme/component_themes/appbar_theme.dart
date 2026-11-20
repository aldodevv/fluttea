import 'package:fluttea/core/constants/ui/elevations.dart';
import 'package:material_ui/material_ui.dart';

abstract final class AppAppBarTheme {
  static AppBarTheme build(ColorScheme colors) {
    return AppBarTheme(
      centerTitle: true,
      elevation: Elevations.level0,
      scrolledUnderElevation: Elevations.level1,
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      iconTheme: IconThemeData(color: colors.onSurface),
    );
  }
}
