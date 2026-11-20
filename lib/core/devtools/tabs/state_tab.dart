import 'package:fluttea/app/router/routes.dart';
import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/state/session_state_provider.dart';
import 'package:fluttea/core/widgets/buttons/app_button.dart';
import 'package:fluttea/core/widgets/layout/section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class StateTab extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final sessionNotifier = ref.read(sessionProvider.notifier);

    final statusColor = switch (session) {
      AuthenticatedSession() => context.statusColors.success,
      ExpiredSession() => context.statusColors.warning,
      UnauthenticatedSession() => context.colors.outline,
    };

    return ListView(
      padding: const EdgeInsets.all(Spacing.md),
      children: [
        Section(
          title: 'Session State (Riverpod)',
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(
                        session.runtimeType.toString().replaceFirst('Session', ''),
                        style: context.text.titleSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text('State Details: $session', style: context.text.bodySmall),
                  const SizedBox(height: Spacing.md),
                  Wrap(
                    spacing: Spacing.sm,
                    runSpacing: Spacing.sm,
                    children: [
                      AppButton(
                        label: 'Simulate Login',
                        size: AppButtonSize.small,
                        onPressed: () {
                          sessionNotifier.login(
                            userId: 'usr_dev_42',
                            token: 'jwt_mock_token_12345',
                            email: 'developer@fluttea.local',
                          );
                        },
                      ),
                      AppButton(
                        label: 'Simulate Expiry',
                        size: AppButtonSize.small,
                        variant: AppButtonVariant.tonal,
                        onPressed: sessionNotifier.expire,
                      ),
                      AppButton(
                        label: 'Logout / Reset',
                        size: AppButtonSize.small,
                        variant: AppButtonVariant.outlined,
                        onPressed: sessionNotifier.logout,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.lg),
        Section(
          title: 'Component & State Case Studies',
          subtitle: '5 skenario state nyata: Error Retry, Form, Offline, Empty, dan Scope',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppButton(
                label: 'Buka 5 Studi Kasus State',
                variant: AppButtonVariant.outlined,
                onPressed: () => context.push(AppRoutes.stateExamples),
              ),
              const SizedBox(height: Spacing.sm),
              AppButton(
                label: 'Buka Component UI Gallery',
                variant: AppButtonVariant.outlined,
                onPressed: () => context.push(AppRoutes.gallery),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
