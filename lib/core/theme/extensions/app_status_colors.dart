import 'package:fluttea/core/constants/ui/palette.dart';
import 'package:material_ui/material_ui.dart';

@immutable
final class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const new({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;

  static const light = AppStatusColors(
    success: Palette.success,
    onSuccess: Color(0xFFFFFFFF),
    warning: Palette.warning,
    onWarning: Color(0xFFFFFFFF),
    info: Palette.info,
    onInfo: Color(0xFFFFFFFF),
  );

  static const dark = AppStatusColors(
    success: Palette.successDark,
    onSuccess: Color(0xFF003314),
    warning: Palette.warningDark,
    onWarning: Color(0xFF432000),
    info: Palette.infoDark,
    onInfo: Color(0xFF003258),
  );

  @override
  AppStatusColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
  }) {
    return AppStatusColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
    );
  }

  @override
  AppStatusColors lerp(ThemeExtension<AppStatusColors>? other, double t) {
    if (other is! AppStatusColors) return this;
    return AppStatusColors(
      success: Color.lerp(success, other.success, t) ?? success,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t) ?? onSuccess,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      onWarning: Color.lerp(onWarning, other.onWarning, t) ?? onWarning,
      info: Color.lerp(info, other.info, t) ?? info,
      onInfo: Color.lerp(onInfo, other.onInfo, t) ?? onInfo,
    );
  }
}
