import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/widgets/layout/app_scaffold.dart';
import 'package:fluttea/core/widgets/states/async_view.dart';
import 'package:fluttea/core/widgets/states/empty_view.dart';
import 'package:fluttea/features/_template/domain/models/template_model.dart';
import 'package:fluttea/features/_template/presentation/widgets/template_card.dart';
import 'package:fluttea/features/_template/state/template_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class TemplateScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(templateNotifierProvider);

    return AppScaffold(
      appBar: AppBar(title: Text(context.l10n.templateTitle)),
      body: AsyncView<TemplateModel?>(
        value: state,
        onRetry: () => ref.read(templateNotifierProvider.notifier).load('demo'),
        data: (data) {
          if (data == null) {
            return EmptyView(
              title: context.l10n.templateEmptyTitle,
              message: context.l10n.templateEmptyMessage,
            );
          }
          return Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: TemplateCard(item: data),
          );
        },
      ),
    );
  }
}
