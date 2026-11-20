import 'dart:async';

import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/network/debug/network_inspector.dart';
import 'package:fluttea/core/network/network_providers.dart';
import 'package:fluttea/core/widgets/buttons/app_button.dart';
import 'package:fluttea/core/widgets/feedback/app_snackbar.dart';
import 'package:fluttea/core/widgets/states/empty_view.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class NetworkTab extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<NetworkTab> createState() => _NetworkTabState();
}

class _NetworkTabState extends ConsumerState<NetworkTab> {
  String _filter = 'all';

  void _showTransactionDetails(NetworkTransaction tx) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(Spacing.md),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${tx.method} ${tx.statusCode ?? "ERR"}', style: ctx.text.titleMedium),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Text(tx.url, style: ctx.text.bodySmall),
            const SizedBox(height: Spacing.md),
            AppButton(
              label: 'Copy cURL Command',
              variant: AppButtonVariant.outlined,
              onPressed: () {
                unawaited(Clipboard.setData(ClipboardData(text: tx.toCurl())));
                Navigator.pop(ctx);
                AppSnackbar.show(context, 'cURL berhasil disalin ke clipboard');
              },
            ),
            const Divider(height: Spacing.xl),
            Text('Request Headers:', style: ctx.text.labelMedium),
            Text(tx.requestHeaders.toString(), style: ctx.text.bodySmall),
            if (tx.requestBody != null) ...[
              const SizedBox(height: Spacing.md),
              Text('Request Body:', style: ctx.text.labelMedium),
              Text(tx.requestBody.toString(), style: ctx.text.bodySmall),
            ],
            const SizedBox(height: Spacing.md),
            Text('Response Body:', style: ctx.text.labelMedium),
            Text(
              tx.responseBody?.toString() ?? tx.error ?? 'No response',
              style: ctx.text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inspector = ref.watch(networkInspectorProvider);
    var list = inspector.transactions;

    if (_filter == 'success') {
      list = list.where((t) => t.isSuccess).toList();
    } else if (_filter == 'error') {
      list = list.where((t) => !t.isSuccess).toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(Spacing.sm),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _filter == 'all',
                onSelected: (_) => setState(() => _filter = 'all'),
              ),
              const SizedBox(width: Spacing.xs),
              ChoiceChip(
                label: const Text('2xx OK'),
                selected: _filter == 'success',
                onSelected: (_) => setState(() => _filter = 'success'),
              ),
              const SizedBox(width: Spacing.xs),
              ChoiceChip(
                label: const Text('Error'),
                selected: _filter == 'error',
                onSelected: (_) => setState(() => _filter = 'error'),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: 'Clear Transactions',
                onPressed: () {
                  inspector.clear();
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: list.isEmpty
              ? const EmptyView(
                  title: 'Belum Ada Transaksi HTTP',
                  message: 'Kirim request lewat aplikasi untuk melihat log jaringan.',
                )
              : ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tx = list[index];
                    final isOk = tx.isSuccess;
                    final statusColor = isOk ? context.statusColors.success : context.colors.error;

                    return ListTile(
                      dense: true,
                      leading: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Spacing.xs, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(Spacing.xs),
                        ),
                        child: Text(
                          tx.statusCode?.toString() ?? 'ERR',
                          style: context.text.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        '${tx.method} ${tx.url}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${tx.durationMs}ms • ${tx.timestamp.toIso8601String().substring(11, 19)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () {
                          unawaited(Clipboard.setData(ClipboardData(text: tx.toCurl())));
                          AppSnackbar.show(context, 'cURL berhasil disalin');
                        },
                      ),
                      onTap: () => _showTransactionDetails(tx),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
