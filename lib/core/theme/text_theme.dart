import 'package:material_ui/material_ui.dart';

abstract final class AppTextTheme {
  static TextTheme build(ColorScheme colors) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: colors.onSurface,
      ),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, color: colors.onSurface),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: colors.onSurface),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: colors.onSurface),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: colors.onSurface),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: colors.onSurface),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: colors.onSurface),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: colors.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colors.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: colors.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: colors.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: colors.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: colors.onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: colors.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}
