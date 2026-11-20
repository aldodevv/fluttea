import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:material_ui/material_ui.dart';

class AppLoader extends StatelessWidget {
  const new({super.key, this.message, this.size = 36.0});

  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: Spacing.md),
            Text(
              message!,
              style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
