import 'dart:async';

import 'package:fluttea/app/providers.dart';
import 'package:fluttea/app/router/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class DevToolsTrigger extends ConsumerStatefulWidget {
  const new({required this.child, this.requiredTapCount = 5, super.key});

  final Widget child;
  final int requiredTapCount;

  @override
  ConsumerState<DevToolsTrigger> createState() => _DevToolsTriggerState();
}

class _DevToolsTriggerState extends ConsumerState<DevToolsTrigger> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTapTime == null || now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }
    _lastTapTime = now;

    if (_tapCount >= widget.requiredTapCount) {
      _tapCount = 0;
      unawaited(context.push(AppRoutes.devTools));
    }
  }

  @override
  Widget build(BuildContext context) {
    final env = ref.watch(appEnvProvider);
    if (!env.devToolsEnabled) return widget.child;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _handleTap,
      child: widget.child,
    );
  }
}
