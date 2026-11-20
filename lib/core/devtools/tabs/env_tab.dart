import 'dart:async';

import 'package:fluttea/app/providers.dart';
import 'package:fluttea/core/constants/storage/storage_keys.dart';
import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/network/network_providers.dart';
import 'package:fluttea/core/storage/prefs/preferences_storage.dart';
import 'package:fluttea/core/widgets/buttons/app_button.dart';
import 'package:fluttea/core/widgets/feedback/app_snackbar.dart';
import 'package:fluttea/core/widgets/inputs/app_text_field.dart';
import 'package:fluttea/core/widgets/layout/section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class EnvTab extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<EnvTab> createState() => _EnvTabState();
}

class _EnvTabState extends ConsumerState<EnvTab> {
  final _urlController = TextEditingController();
  final _prefs = PreferencesStorage();
  String? _currentOverride;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadCurrentOverride());
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentOverride() async {
    final override = await _prefs.getString(StorageKeys.baseUrlOverride);
    if (!mounted) return;
    setState(() {
      _currentOverride = override;
      if (override != null) _urlController.text = override;
    });
  }

  Future<void> _applyOverride(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;
    setState(() => _isLoading = true);

    await _prefs.setString(StorageKeys.baseUrlOverride, trimmed);
    ref
      ..invalidate(baseUrlResolverProvider)
      ..invalidate(networkConfigProvider)
      ..invalidate(apiClientProvider);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _currentOverride = trimmed;
    });
    AppSnackbar.show(context, 'Base URL override diterapkan: $trimmed');
  }

  Future<void> _resetOverride() async {
    setState(() => _isLoading = true);
    await _prefs.remove(StorageKeys.baseUrlOverride);
    ref
      ..invalidate(baseUrlResolverProvider)
      ..invalidate(networkConfigProvider)
      ..invalidate(apiClientProvider);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _currentOverride = null;
      _urlController.clear();
    });
    AppSnackbar.show(context, 'Base URL dikembalikan ke default');
  }

  @override
  Widget build(BuildContext context) {
    final env = ref.watch(appEnvProvider);

    return ListView(
      padding: const EdgeInsets.all(Spacing.md),
      children: [
        Section(
          title: 'Environment Configuration',
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Flavor: ${env.flavor.name}', style: context.text.titleSmall),
                  const SizedBox(height: Spacing.xs),
                  Text('App Name: ${env.name}', style: context.text.bodyMedium),
                  const SizedBox(height: Spacing.xs),
                  Text('Default Base URL: ${env.baseUrl}', style: context.text.bodySmall),
                  const SizedBox(height: Spacing.xs),
                  Text('Certificate Pinning: ${env.pinningEnabled ? "Enabled" : "Disabled (Dev)"}'),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    'Active Override: ${_currentOverride ?? "None (Using Default)"}',
                    style: context.text.bodyMedium?.copyWith(
                      color: _currentOverride != null
                          ? context.statusColors.warning
                          : context.statusColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.lg),
        Section(
          title: 'Base URL Override',
          subtitle: 'Ubah target API dinamis tanpa build ulang',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _urlController,
                label: 'Target API URL',
                hint: 'https://www.mock-server.com',
              ),
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: Spacing.xs,
                children: [
                  ActionChip(
                    label: const Text('Mock Server'),
                    onPressed: () {
                      _urlController.text = 'https://www.mock-server.com';
                      unawaited(_applyOverride('https://www.mock-server.com'));
                    },
                  ),
                  ActionChip(
                    label: const Text('Localhost (8080)'),
                    onPressed: () {
                      _urlController.text = 'http://127.0.0.1:8080';
                      unawaited(_applyOverride('http://127.0.0.1:8080'));
                    },
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  AppButton(
                    label: 'Simpan Override',
                    isLoading: _isLoading,
                    onPressed: () => unawaited(_applyOverride(_urlController.text)),
                  ),
                  const SizedBox(width: Spacing.sm),
                  AppButton(
                    label: 'Reset Default',
                    variant: AppButtonVariant.outlined,
                    onPressed: _currentOverride != null ? () => unawaited(_resetOverride()) : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
