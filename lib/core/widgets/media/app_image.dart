import 'package:fluttea/core/constants/ui/radii.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:material_ui/material_ui.dart';

class AppImage extends StatelessWidget {
  const new({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = Radii.md,
    this.placeholder,
    this.errorWidget,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ??
              Container(
                width: width,
                height: height,
                color: context.colors.surfaceContainerHighest,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                    strokeWidth: 2,
                  ),
                ),
              );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              Container(
                width: width,
                height: height,
                color: context.colors.surfaceContainerHighest,
                child: Icon(Icons.broken_image_outlined, color: context.colors.onSurfaceVariant),
              );
        },
      ),
    );
  }
}
