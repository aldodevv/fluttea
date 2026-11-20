import 'package:fluttea/core/constants/ui/radii.dart';
import 'package:material_ui/material_ui.dart';

abstract final class AppBottomSheetTheme {
  static BottomSheetThemeData build(ColorScheme colors) {
    return BottomSheetThemeData(
      showDragHandle: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg)),
      ),
    );
  }
}
