import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/widgets/buttons/app_button.dart';
import 'package:material_ui/material_ui.dart';

class EmptyView extends StatelessWidget {
  const new({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: context.colors.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: Spacing.md),
            Text(title, style: context.text.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: Spacing.xs),
              Text(
                message!,
                style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: Spacing.lg),
              AppButton(label: actionLabel!, variant: AppButtonVariant.tonal, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
