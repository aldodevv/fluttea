import 'package:fluttea/core/utils/ui/keyboard.dart';
import 'package:material_ui/material_ui.dart';

class KeyboardDismiss extends StatelessWidget {
  const new({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: KeyboardUtils.dismiss,
      child: child,
    );
  }
}
