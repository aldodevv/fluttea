import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:material_ui/material_ui.dart';

class OfflineBanner extends StatelessWidget {
  const new({super.key, this.message, this.isOffline = true});

  final String? message;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: context.statusColors.warning,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 16, color: context.statusColors.onWarning),
            const SizedBox(width: Spacing.xs),
            Text(
              message ?? context.l10n.offlineMessage,
              style: context.text.labelSmall?.copyWith(
                color: context.statusColors.onWarning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
