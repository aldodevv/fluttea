import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:material_ui/material_ui.dart';

class RouteScope extends StatelessWidget {
  const new({super.key, required this.child, this.overrides = const []});

  final Widget child;
  final List<Override> overrides;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(overrides: overrides, child: child);
  }
}
