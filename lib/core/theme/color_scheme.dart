import 'package:fluttea/core/constants/ui/palette.dart';
import 'package:material_ui/material_ui.dart';

abstract final class AppColorScheme {
  static ColorScheme light() {
    return ColorScheme.fromSeed(seedColor: Palette.seed, error: Palette.error);
  }

  static ColorScheme dark() {
    return ColorScheme.fromSeed(
      seedColor: Palette.seed,
      brightness: Brightness.dark,
      error: Palette.errorDark,
    );
  }
}
