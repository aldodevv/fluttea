import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/widgets/buttons/app_button.dart';
import 'package:material_ui/material_ui.dart';

class ErrorView extends StatelessWidget {
  const new({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.error_outline,
    this.retryLabel,
    this.onRetry,
  });

  final String message;
  final String? title;
  final IconData icon;
  final String? retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: context.colors.error),
            const SizedBox(height: Spacing.md),
            Text(
              title ?? context.l10n.errorTitle,
              style: context.text.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              message,
              style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: Spacing.lg),
              AppButton(label: retryLabel ?? context.l10n.retry, onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
