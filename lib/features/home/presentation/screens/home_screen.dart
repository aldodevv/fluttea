import 'package:fluttea/app/providers.dart';
import 'package:fluttea/app/router/routes.dart';
import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/state/session_state_provider.dart';
import 'package:fluttea/core/widgets/buttons/app_button.dart';
import 'package:fluttea/core/widgets/layout/app_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class HomeScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(appEnvProvider);
    final session = ref.watch(sessionProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text(env.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: context.l10n.homeSettingsTooltip,
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (session is AuthenticatedSession) ...[
                  Text(
                    context.l10n.homeGreeting(session.email ?? session.userId),
                    textAlign: TextAlign.center,
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                ],
                Text(
                  env.baseUrl,
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(color: context.colors.outline),
                ),
                const SizedBox(height: Spacing.lg),
                AppButton(
                  label: context.l10n.homeAppSettings,
                  variant: AppButtonVariant.tonal,
                  icon: const Icon(Icons.settings_outlined, size: 18),
                  onPressed: () => context.push(AppRoutes.settings),
                ),
                if (env.devToolsEnabled) ...[
                  const SizedBox(height: Spacing.sm),
                  AppButton(
                    label: context.l10n.homeOpenDevToolsHub,
                    icon: const Icon(Icons.developer_mode_rounded, size: 18),
                    onPressed: () => context.push(AppRoutes.devTools),
                  ),
                  const SizedBox(height: Spacing.sm),
                  AppButton(
                    label: context.l10n.homeOpenUiGallery,
                    variant: AppButtonVariant.outlined,
                    icon: const Icon(Icons.palette_outlined, size: 18),
                    onPressed: () => context.push(AppRoutes.gallery),
                  ),
                  const SizedBox(height: Spacing.sm),
                  AppButton(
                    label: context.l10n.homeOpenStateExamples,
                    variant: AppButtonVariant.outlined,
                    icon: const Icon(Icons.science_outlined, size: 18),
                    onPressed: () => context.push(AppRoutes.stateExamples),
                  ),
                  const SizedBox(height: Spacing.sm),
                  AppButton(
                    label: context.l10n.homeOpenNetworkExamples,
                    variant: AppButtonVariant.outlined,
                    icon: const Icon(Icons.cloud_sync_outlined, size: 18),
                    onPressed: () => context.push(AppRoutes.networkExamples),
                  ),
                  const SizedBox(height: Spacing.sm),
                  AppButton(
                    label: context.l10n.homeOpenSecurityShowcase,
                    variant: AppButtonVariant.outlined,
                    icon: const Icon(Icons.security_rounded, size: 18),
                    onPressed: () => context.push(AppRoutes.securityExamples),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
