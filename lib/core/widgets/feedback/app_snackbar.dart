import 'package:fluttea/core/constants/ui/durations.dart';
import 'package:fluttea/core/constants/ui/radii.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:material_ui/material_ui.dart';

enum AppSnackbarVariant { success, error, warning, info }

abstract final class AppSnackbar {
  static void show(
    BuildContext context,
    String message, {
    AppSnackbarVariant variant = AppSnackbarVariant.info,
    Duration duration = AppDurations.snackbar,
    SnackBarAction? action,
  }) {
    final (bgColor, fgColor, icon) = switch (variant) {
      AppSnackbarVariant.success => (
        context.statusColors.success,
        context.statusColors.onSuccess,
        Icons.check_circle_outline,
      ),
      AppSnackbarVariant.error => (
        context.colors.error,
        context.colors.onError,
        Icons.error_outline,
      ),
      AppSnackbarVariant.warning => (
        context.statusColors.warning,
        context.statusColors.onWarning,
        Icons.warning_amber_outlined,
      ),
      AppSnackbarVariant.info => (
        context.colors.inverseSurface,
        context.colors.onInverseSurface,
        Icons.info_outline,
      ),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: fgColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(message, style: context.text.bodyMedium?.copyWith(color: fgColor)),
              ),
            ],
          ),
          backgroundColor: bgColor,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
          action: action,
        ),
      );
  }
}
