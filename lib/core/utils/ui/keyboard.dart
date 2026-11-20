import 'package:material_ui/material_ui.dart';

abstract final class KeyboardUtils {
  static void dismiss() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static bool isVisible(BuildContext context) {
    return MediaQuery.viewInsetsOf(context).bottom > 0;
  }
}
