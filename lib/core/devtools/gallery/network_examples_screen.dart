import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/errors/result.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/network/api_client.dart';
import 'package:fluttea/core/network/network_providers.dart';
import 'package:fluttea/core/widgets/buttons/app_button.dart';
import 'package:fluttea/core/widgets/feedback/app_snackbar.dart';
import 'package:fluttea/core/widgets/layout/app_scaffold.dart';
import 'package:fluttea/core/widgets/layout/section.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class NetworkExamplesScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<NetworkExamplesScreen> createState() => _NetworkExamplesScreenState();
}

class _NetworkExamplesScreenState extends ConsumerState<NetworkExamplesScreen> {
  String _lastResponse = 'Belum ada request yang dikirim.';
  bool _isLoading = false;

  Future<void> _executeGet() async {
    setState(() => _isLoading = true);
    final client = ref.read(apiClientProvider);

    // Contoh request ke Mock-Server endpoint
    final result = await client.request<Map<String, dynamic>>(
      HttpMethod.get,
      '/mock/status',
      extra: {'mock': true},
      fromJson: (json) => json is Map ? json.cast<String, dynamic>() : {'data': json},
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _lastResponse = switch (result) {
        Ok(:final value) => 'OK (Success):\n$value',
        Err(:final failure) => 'Error (${failure.code}):\n${failure.message}',
      };
    });
  }

  Future<void> _executePost() async {
    setState(() => _isLoading = true);
    final client = ref.read(apiClientProvider);

    final result = await client.request<Map<String, dynamic>>(
      HttpMethod.post,
      '/mock/users',
      data: {'name': 'Fluttea Dev', 'role': 'Admin'},
      fromJson: (json) => json is Map ? json.cast<String, dynamic>() : {'result': json},
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _lastResponse = switch (result) {
        Ok(:final value) => 'OK (Success Created):\n$value',
        Err(:final failure) => 'Error (${failure.code}):\n${failure.message}',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(networkProfileProvider);
    final inspector = ref.watch(networkInspectorProvider);
    final transactions = inspector.transactions;

    return AppScaffold(
      appBar: AppBar(title: const Text('Network & Mock Server')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Active Configuration
            Section(
              title: '1. Network Profile & Base URL',
              subtitle: 'Konfigurasi Lego: Profile, Mock Server, Pinning & Proxy',
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Profile: ${profile.name}', style: context.text.titleSmall),
                      const SizedBox(height: Spacing.xs),
                      Text('Base URL: ${profile.defaultBaseUrl}'),
                      const SizedBox(height: Spacing.xs),
                      Text('Pinning: ${profile.pinningEnabled ? "Enabled" : "Disabled (Dev)"}'),
                      const SizedBox(height: Spacing.xs),
                      Text('Proxy: ${profile.proxy}'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),

            // Section 2: Request Playground
            Section(
              title: '2. Request Playground',
              subtitle: 'Eksekusi HTTP get/post terproteksi Result<T>',
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: Spacing.sm,
                        runSpacing: Spacing.sm,
                        children: [
                          AppButton(
                            label: 'GET /mock/status',
                            size: AppButtonSize.small,
                            isLoading: _isLoading,
                            onPressed: _executeGet,
                          ),
                          AppButton(
                            label: 'POST /mock/users',
                            size: AppButtonSize.small,
                            variant: AppButtonVariant.tonal,
                            isLoading: _isLoading,
                            onPressed: _executePost,
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.md),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(Spacing.sm),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _lastResponse,
                          style: context.text.bodySmall?.copyWith(fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),

            // Section 3: Live Network Inspector
            Section(
              title: '3. Network Inspector (Last ${transactions.length} Requests)',
              subtitle: 'Ring buffer transaksi untuk DevTools & cURL export',
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: transactions.isEmpty
                      ? const Text('Belum ada transaksi di buffer.')
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactions.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final tx = transactions[index];
                            final isOk = tx.isSuccess;
                            return ListTile(
                              dense: true,
                              leading: Text(
                                '${tx.statusCode ?? "ERR"}',
                                style: context.text.labelLarge?.copyWith(
                                  color: isOk ? context.statusColors.success : context.colors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              title: Text('${tx.method} ${tx.url}'),
                              subtitle: Text('${tx.durationMs}ms - ID: ${tx.id}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.copy, size: 18),
                                tooltip: 'Copy cURL',
                                onPressed: () async {
                                  await Clipboard.setData(ClipboardData(text: tx.toCurl()));
                                  if (context.mounted) {
                                    AppSnackbar.show(context, 'cURL disalin ke clipboard!');
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }
}
