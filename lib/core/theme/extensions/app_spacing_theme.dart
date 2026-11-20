import 'dart:ui';

import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:material_ui/material_ui.dart';

@immutable
final class AppSpacingTheme extends ThemeExtension<AppSpacingTheme> {
  const new({
    this.xs = Spacing.xs,
    this.sm = Spacing.sm,
    this.md = Spacing.md,
    this.lg = Spacing.lg,
    this.xl = Spacing.xl,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;

  static const regular = AppSpacingTheme();

  @override
  AppSpacingTheme copyWith({double? xs, double? sm, double? md, double? lg, double? xl}) {
    return AppSpacingTheme(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
    );
  }

  @override
  AppSpacingTheme lerp(ThemeExtension<AppSpacingTheme>? other, double t) {
    if (other is! AppSpacingTheme) return this;
    return AppSpacingTheme(
      xs: lerpDouble(xs, other.xs, t) ?? xs,
      sm: lerpDouble(sm, other.sm, t) ?? sm,
      md: lerpDouble(md, other.md, t) ?? md,
      lg: lerpDouble(lg, other.lg, t) ?? lg,
      xl: lerpDouble(xl, other.xl, t) ?? xl,
    );
  }
}
