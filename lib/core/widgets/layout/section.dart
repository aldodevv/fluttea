import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:material_ui/material_ui.dart';

class Section extends StatelessWidget {
  const new({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
    this.padding = const EdgeInsets.symmetric(horizontal: Spacing.md),
  });

  final String title;
  final Widget child;
  final String? subtitle;
  final Widget? action;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.titleMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: Spacing.xs),
                      Text(
                        subtitle!,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?action,
            ],
          ),
          const SizedBox(height: Spacing.sm),
          child,
        ],
      ),
    );
  }
}
