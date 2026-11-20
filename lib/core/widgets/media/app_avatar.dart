import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/utils/string/formatters.dart';
import 'package:material_ui/material_ui.dart';

class AppAvatar extends StatelessWidget {
  const new({super.key, this.imageUrl, this.name, this.radius = 24.0, this.backgroundColor});

  final String? imageUrl;
  final String? name;
  final double radius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? context.colors.primaryContainer;
    final initials = name != null ? StringFormatters.initials(name!) : '';

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: effectiveBg,
        backgroundImage: NetworkImage(imageUrl!),
        onBackgroundImageError: (_, _) {},
        child: initials.isNotEmpty
            ? Text(
                initials,
                style: context.text.titleMedium?.copyWith(color: context.colors.onPrimaryContainer),
              )
            : null,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: effectiveBg,
      child: initials.isNotEmpty
          ? Text(
              initials,
              style: context.text.titleMedium?.copyWith(color: context.colors.onPrimaryContainer),
            )
          : Icon(Icons.person, size: radius, color: context.colors.onPrimaryContainer),
    );
  }
}
