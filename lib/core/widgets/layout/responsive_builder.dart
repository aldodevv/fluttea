import 'package:fluttea/core/constants/ui/breakpoints.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:material_ui/material_ui.dart';

class ResponsiveBuilder extends StatelessWidget {
  const new({super.key, required this.mobile, this.tablet, this.desktop});

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;

    if (width >= Breakpoints.desktop && desktop != null) {
      return desktop!(context);
    }
    if (width >= Breakpoints.tablet && tablet != null) {
      return tablet!(context);
    }
    return mobile(context);
  }
}
