import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:material_ui/material_ui.dart';

abstract final class AppBottomSheet {
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null) ...[
                  Text(title, style: sheetContext.text.titleLarge, textAlign: TextAlign.center),
                  const SizedBox(height: Spacing.md),
                ],
                child,
              ],
            ),
          ),
        );
      },
    );
  }
}
