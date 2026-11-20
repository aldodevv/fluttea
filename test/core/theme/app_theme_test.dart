import 'package:fluttea/core/constants/ui/palette.dart';
import 'package:fluttea/core/theme/app_theme.dart';
import 'package:fluttea/core/theme/extensions/app_spacing_theme.dart';
import 'package:fluttea/core/theme/extensions/app_status_colors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('AppTheme', () {
    test('light theme provides Material 3 and proper scheme', () {
      final theme = AppTheme.light();
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, equals(Brightness.light));
      expect(theme.colorScheme.primary, isNotNull);
      expect(theme.colorScheme.error, equals(Palette.error));
    });

    test('dark theme provides Material 3 and dark scheme', () {
      final theme = AppTheme.dark();
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.colorScheme.error, equals(Palette.errorDark));
    });

    test('theme includes AppStatusColors and AppSpacingTheme extensions', () {
      final lightTheme = AppTheme.light();
      final statusColors = lightTheme.extension<AppStatusColors>();
      final spacing = lightTheme.extension<AppSpacingTheme>();

      expect(statusColors, isNotNull);
      expect(statusColors?.success, equals(Palette.success));
      expect(statusColors?.warning, equals(Palette.warning));
      expect(statusColors?.info, equals(Palette.info));

      expect(spacing, isNotNull);
      expect(spacing?.md, equals(16.0));
    });

    test('AppStatusColors copyWith and lerp', () {
      const original = AppStatusColors.light;
      final copied = original.copyWith(success: Colors.green);
      expect(copied.success, equals(Colors.green));
      expect(copied.warning, equals(original.warning));

      final lerped = original.lerp(AppStatusColors.dark, 0.5);
      expect(lerped.success, isNotNull);
      expect(original.lerp(null, 0.5), equals(original));
    });

    test('AppSpacingTheme copyWith and lerp', () {
      const original = AppSpacingTheme.regular;
      final copied = original.copyWith(md: 20);
      expect(copied.md, equals(20));
      expect(copied.sm, equals(original.sm));

      final lerped = original.lerp(const AppSpacingTheme(md: 32), 0.5);
      expect(lerped.md, equals(24.0));
      expect(original.lerp(null, 0.5), equals(original));
    });
  });
}
