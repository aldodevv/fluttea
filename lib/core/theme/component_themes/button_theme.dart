import 'package:fluttea/core/constants/ui/radii.dart';
import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:material_ui/material_ui.dart';

abstract final class AppButtonTheme {
  static const _minTouchTarget = Size(64, 48);

  static ElevatedButtonThemeData elevated(ColorScheme colors) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: _minTouchTarget,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.sm),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
      ),
    );
  }

  static FilledButtonThemeData filled(ColorScheme colors) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: _minTouchTarget,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.sm),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
      ),
    );
  }

  static OutlinedButtonThemeData outlined(ColorScheme colors) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: _minTouchTarget,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.sm),
        side: BorderSide(color: colors.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
      ),
    );
  }

  static TextButtonThemeData text(ColorScheme colors) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: _minTouchTarget,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
      ),
    );
  }
}
