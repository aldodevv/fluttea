import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/widgets/buttons/app_button.dart';
import 'package:material_ui/material_ui.dart';

abstract final class AppDialog {
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
    Widget? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: icon,
          title: Text(title, style: dialogContext.text.titleLarge),
          content: Text(message, style: dialogContext.text.bodyMedium),
          actions: [
            if (cancelLabel != null)
              AppButton(
                label: cancelLabel,
                variant: AppButtonVariant.text,
                onPressed: () => Navigator.of(dialogContext).pop(false),
              ),
            AppButton(
              label: confirmLabel ?? dialogContext.l10n.ok,
              variant: isDestructive ? AppButtonVariant.filled : AppButtonVariant.filled,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );
  }
}
