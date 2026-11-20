import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/features/_template/domain/models/template_model.dart';
import 'package:material_ui/material_ui.dart';

class TemplateCard extends StatelessWidget {
  const new({required this.item, this.onTap, super.key});

  final TemplateModel item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.sm),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: context.text.titleMedium),
              const SizedBox(height: Spacing.xs),
              Text(item.description, style: context.text.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
