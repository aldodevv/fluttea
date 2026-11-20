import 'package:fluttea/app/providers.dart';
import 'package:fluttea/app/router/routes.dart';
import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/widgets/layout/app_scaffold.dart';
import 'package:fluttea/features/auth/presentation/widgets/login_form.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class LoginScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(appEnvProvider);

    return AppScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.coffee_rounded,
                        size: 38,
                        color: context.colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  Text(
                    context.l10n.authWelcomeTitle,
                    textAlign: TextAlign.center,
                    style: context.text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    context.l10n.authWelcomeSubtitle(env.name),
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium?.copyWith(color: context.colors.outline),
                  ),
                  const SizedBox(height: Spacing.xl),
                  LoginForm(onSuccess: () => context.go(AppRoutes.home)),
                  const SizedBox(height: Spacing.xl),
                  if (env.devToolsEnabled) ...[
                    Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.bug_report_outlined, size: 16),
                        label: Text(
                          context.l10n.authOpenDevTools,
                          style: context.text.labelSmall?.copyWith(color: context.colors.outline),
                        ),
                        onPressed: () => context.push(AppRoutes.devTools),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
