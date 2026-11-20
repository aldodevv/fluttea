import 'dart:async';

import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/logging/app_log.dart';
import 'package:fluttea/core/widgets/feedback/app_snackbar.dart';
import 'package:fluttea/core/widgets/states/empty_view.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:talker/talker.dart';

class LogTab extends StatefulWidget {
  const new({super.key});

  @override
  State<LogTab> createState() => _LogTabState();
}

class _LogTabState extends State<LogTab> {
  LogLevel? _filterLevel;

  Color _getLevelColor(LogLevel? level, BuildContext context) {
    return switch (level) {
      LogLevel.error || LogLevel.critical => context.colors.error,
      LogLevel.warning => context.statusColors.warning,
      LogLevel.info => context.statusColors.info,
      _ => context.colors.outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final history = AppLog.talker.history;
    final filtered = _filterLevel == null
        ? history
        : history.where((d) => d.logLevel == _filterLevel).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(Spacing.sm),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _filterLevel == null,
                onSelected: (_) => setState(() => _filterLevel = null),
              ),
              const SizedBox(width: Spacing.xs),
              ChoiceChip(
                label: const Text('Info'),
                selected: _filterLevel == LogLevel.info,
                onSelected: (_) => setState(() => _filterLevel = LogLevel.info),
              ),
              const SizedBox(width: Spacing.xs),
              ChoiceChip(
                label: const Text('Warning'),
                selected: _filterLevel == LogLevel.warning,
                onSelected: (_) => setState(() => _filterLevel = LogLevel.warning),
              ),
              const SizedBox(width: Spacing.xs),
              ChoiceChip(
                label: const Text('Error'),
                selected: _filterLevel == LogLevel.error,
                onSelected: (_) => setState(() => _filterLevel = LogLevel.error),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: 'Clear Log History',
                onPressed: () {
                  AppLog.talker.cleanHistory();
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyView(
                  title: 'Log Masih Kosong',
                  message: 'Belum ada log tercatat di Talker history.',
                )
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = filtered[filtered.length - 1 - index];
                    final level = item.logLevel;
                    final color = _getLevelColor(level, context);
                    final timeStr = item.time.toIso8601String().substring(11, 19);

                    return ListTile(
                      dense: true,
                      leading: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Spacing.xs, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(Spacing.xs),
                        ),
                        child: Text(
                          level?.name.toUpperCase() ?? 'LOG',
                          style: context.text.labelSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        item.message ?? item.generateTextMessage(),
                        style: context.text.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        timeStr,
                        style: context.text.labelSmall?.copyWith(color: context.colors.outline),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy, size: 16),
                        onPressed: () {
                          unawaited(
                            Clipboard.setData(ClipboardData(text: item.generateTextMessage())),
                          );
                          AppSnackbar.show(context, 'Log disalin ke clipboard');
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
