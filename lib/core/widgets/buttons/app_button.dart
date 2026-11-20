import 'package:fluttea/core/constants/ui/radii.dart';
import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:material_ui/material_ui.dart';

enum AppButtonVariant { filled, tonal, outlined, text }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  const new({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = switch (size) {
      AppButtonSize.small => 36.0,
      AppButtonSize.medium => 48.0,
      AppButtonSize.large => 56.0,
    };

    final content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_getLoadingColor(context)),
            ),
          ),
          const SizedBox(width: Spacing.sm),
        ] else if (icon != null) ...[
          icon!,
          const SizedBox(width: Spacing.sm),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: switch (size) {
              AppButtonSize.small => context.text.labelMedium,
              AppButtonSize.medium => context.text.labelLarge,
              AppButtonSize.large => context.text.titleMedium,
            },
          ),
        ),
      ],
    );

    final style = _buildStyle(context, effectiveHeight);

    final button = switch (variant) {
      AppButtonVariant.filled => FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: content,
      ),
      AppButtonVariant.tonal => FilledButton.tonal(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: content,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: content,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: content,
      ),
    };

    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: label,
      child: isFullWidth ? SizedBox(width: double.infinity, child: button) : button,
    );
  }

  ButtonStyle _buildStyle(BuildContext context, double height) {
    return ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(isFullWidth ? double.infinity : 64, height)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
      ),
    );
  }

  Color _getLoadingColor(BuildContext context) {
    return switch (variant) {
      AppButtonVariant.filled => context.colors.onPrimary,
      AppButtonVariant.tonal => context.colors.onSecondaryContainer,
      AppButtonVariant.outlined => context.colors.primary,
      AppButtonVariant.text => context.colors.primary,
    };
  }
}
