import 'package:fluttea/core/widgets/layout/keyboard_dismiss.dart';
import 'package:material_ui/material_ui.dart';

class AppScaffold extends StatelessWidget {
  const new({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.useSafeArea = true,
    this.dismissKeyboardOnTap = true,
    this.backgroundColor,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final bool useSafeArea;
  final bool dismissKeyboardOnTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    var content = body;

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    if (dismissKeyboardOnTap) {
      content = KeyboardDismiss(child: content);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
    );
  }
}
