import 'dart:async';

import 'package:fluttea/app/providers.dart';
import 'package:fluttea/app/router/routes.dart';
import 'package:fluttea/core/constants/app/locale_codes.dart';
import 'package:fluttea/core/constants/ui/radii.dart';
import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/state/session_state_provider.dart';
import 'package:fluttea/core/widgets/buttons/app_button.dart';
import 'package:fluttea/core/widgets/feedback/app_snackbar.dart';
import 'package:fluttea/core/widgets/layout/app_scaffold.dart';
import 'package:fluttea/core/widgets/layout/section.dart';
import 'package:fluttea/features/auth/state/auth_notifier.dart';
import 'package:fluttea/features/settings/state/settings_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class SettingsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final session = ref.watch(sessionProvider);
    final env = ref.watch(appEnvProvider);

    return AppScaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
        children: [
          Section(
            title: context.l10n.settingsAppearanceTitle,
            subtitle: context.l10n.settingsAppearanceSubtitle,
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: const Icon(Icons.brightness_auto_rounded),
                  label: Text(context.l10n.settingsThemeSystem),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode_rounded),
                  label: Text(context.l10n.settingsThemeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode_rounded),
                  label: Text(context.l10n.settingsThemeDark),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (modes) {
                if (modes.isNotEmpty) {
                  unawaited(settingsNotifier.setThemeMode(modes.first));
                }
              },
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Section(
            title: context.l10n.settingsLanguageTitle,
            subtitle: context.l10n.settingsLanguageSubtitle,
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: LocaleCodes.id,
                  icon: const Icon(Icons.language_rounded),
                  label: Text(context.l10n.settingsLanguageId),
                ),
                ButtonSegment(
                  value: LocaleCodes.en,
                  icon: const Icon(Icons.language_rounded),
                  label: Text(context.l10n.settingsLanguageEn),
                ),
              ],
              selected: {settings.locale.languageCode},
              onSelectionChanged: (locales) {
                if (locales.isNotEmpty) {
                  unawaited(settingsNotifier.setLocale(Locale(locales.first)));
                }
              },
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Section(
            title: context.l10n.settingsSecurityTitle,
            subtitle: context.l10n.settingsSecuritySubtitle,
            child: Material(
              color: context.colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(Radii.md),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    secondary: const Icon(Icons.fingerprint_rounded),
                    title: Text(
                      context.l10n.settingsBiometricsTitle,
                      style: context.text.bodyMedium,
                    ),
                    subtitle: Text(
                      context.l10n.settingsBiometricsSubtitle,
                      style: context.text.bodySmall?.copyWith(color: context.colors.outline),
                    ),
                    value: settings.biometricsEnabled,
                    onChanged: settingsNotifier.setBiometrics,
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    secondary: const Icon(Icons.notifications_active_outlined),
                    title: Text(
                      context.l10n.settingsNotificationsTitle,
                      style: context.text.bodyMedium,
                    ),
                    subtitle: Text(
                      context.l10n.settingsNotificationsSubtitle,
                      style: context.text.bodySmall?.copyWith(color: context.colors.outline),
                    ),
                    value: settings.notificationsEnabled,
                    onChanged: settingsNotifier.setNotifications,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Section(
            title: context.l10n.settingsAccountTitle,
            subtitle: context.l10n.settingsAccountSubtitle,
            child: Material(
              color: context.colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(Radii.md),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(Spacing.md),
                child: switch (session) {
                  AuthenticatedSession(:final userId, :final email) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: context.colors.primaryContainer,
                            child: Icon(
                              Icons.person_rounded,
                              color: context.colors.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: Spacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  email ?? context.l10n.settingsUserFallback(userId),
                                  style: context.text.titleSmall,
                                ),
                                Text(
                                  context.l10n.settingsUserIdLabel(userId),
                                  style: context.text.bodySmall?.copyWith(
                                    color: context.colors.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.md),
                      AppButton(
                        label: context.l10n.settingsLogoutButton,
                        variant: AppButtonVariant.outlined,
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        onPressed: () async {
                          await ref.read(authNotifierProvider.notifier).logout();
                          if (context.mounted) {
                            AppSnackbar.show(context, context.l10n.settingsLogoutSuccess);
                            context.go(AppRoutes.login);
                          }
                        },
                      ),
                    ],
                  ),
                  _ => Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.settingsNotLoggedIn,
                          style: context.text.bodyMedium,
                        ),
                      ),
                      AppButton(
                        label: context.l10n.authLoginButton,
                        size: AppButtonSize.small,
                        onPressed: () => context.go(AppRoutes.login),
                      ),
                    ],
                  ),
                },
              ),
            ),
          ),
          if (env.devToolsEnabled) ...[
            const SizedBox(height: Spacing.lg),
            Section(
              title: context.l10n.settingsDeveloperTitle,
              subtitle: context.l10n.settingsDeveloperSubtitle(env.name),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    label: context.l10n.settingsOpenDevToolsHub,
                    variant: AppButtonVariant.tonal,
                    icon: const Icon(Icons.developer_mode_rounded, size: 18),
                    onPressed: () => context.push(AppRoutes.devTools),
                  ),
                  const SizedBox(height: Spacing.sm),
                  AppButton(
                    label: context.l10n.settingsOpenUiGallery,
                    variant: AppButtonVariant.outlined,
                    icon: const Icon(Icons.palette_outlined, size: 18),
                    onPressed: () => context.push(AppRoutes.gallery),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
