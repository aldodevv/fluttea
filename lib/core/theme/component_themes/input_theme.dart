import 'package:fluttea/core/constants/ui/radii.dart';
import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:material_ui/material_ui.dart';

abstract final class AppInputTheme {
  static InputDecorationTheme build(ColorScheme colors) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radii.md),
      borderSide: BorderSide(color: colors.outline),
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
      border: baseBorder,
      enabledBorder: baseBorder,
      focusedBorder: baseBorder.copyWith(borderSide: BorderSide(color: colors.primary, width: 2)),
      errorBorder: baseBorder.copyWith(borderSide: BorderSide(color: colors.error)),
      focusedErrorBorder: baseBorder.copyWith(
        borderSide: BorderSide(color: colors.error, width: 2),
      ),
      disabledBorder: baseBorder.copyWith(
        borderSide: BorderSide(color: colors.onSurface.withValues(alpha: 0.12)),
      ),
      labelStyle: TextStyle(color: colors.onSurfaceVariant),
      hintStyle: TextStyle(color: colors.onSurfaceVariant.withValues(alpha: 0.6)),
    );
  }
}
