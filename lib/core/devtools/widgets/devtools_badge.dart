import 'package:fluttea/app/providers.dart';
import 'package:fluttea/app/router/routes.dart';
import 'package:fluttea/core/constants/app/app_info.dart';
import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class DevToolsBadge extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(appEnvProvider);
    if (!env.devToolsEnabled) return const SizedBox.shrink();

    return Positioned(
      bottom: Spacing.lg,
      right: Spacing.md,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(Spacing.sm),
        color: context.colors.primaryContainer,
        child: InkWell(
          borderRadius: BorderRadius.circular(Spacing.sm),
          onTap: () => context.push(AppRoutes.devTools),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.developer_mode, size: 16, color: context.colors.onPrimaryContainer),
                const SizedBox(width: Spacing.xs),
                Text(
                  AppInfo.devToolsBadge,
                  style: context.text.labelSmall?.copyWith(
                    color: context.colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
