import 'dart:async';

import 'package:fluttea/app/router/routes.dart';
import 'package:fluttea/core/constants/app/app_info.dart';
import 'package:fluttea/core/constants/ui/elevations.dart';
import 'package:fluttea/core/constants/ui/radii.dart';
import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class DevToolsFloatingOverlay extends StatefulWidget {
  const new({required this.router, required this.child, super.key});

  final GoRouter router;
  final Widget child;

  @override
  State<DevToolsFloatingOverlay> createState() => _DevToolsFloatingOverlayState();
}

class _DevToolsFloatingOverlayState extends State<DevToolsFloatingOverlay> {
  static const double _pillWidth = 112;
  static const double _pillHeight = 36;

  Offset? _offset;
  late bool _isOnDevTools = _computeIsOnDevTools();

  @override
  void initState() {
    super.initState();
    widget.router.routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void didUpdateWidget(covariant DevToolsFloatingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.router != widget.router) {
      oldWidget.router.routerDelegate.removeListener(_onRouteChanged);
      widget.router.routerDelegate.addListener(_onRouteChanged);
      _isOnDevTools = _computeIsOnDevTools();
    }
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  bool _computeIsOnDevTools() {
    final matches = widget.router.routerDelegate.currentConfiguration.matches;
    if (matches.isEmpty) return false;
    return matches.last.matchedLocation.startsWith(AppRoutes.devTools);
  }

  void _onRouteChanged() {
    final next = _computeIsOnDevTools();
    if (next == _isOnDevTools) return;
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final latest = _computeIsOnDevTools();
        if (latest != _isOnDevTools) {
          setState(() => _isOnDevTools = latest);
        }
      });
      return;
    }
    setState(() => _isOnDevTools = next);
  }

  Offset _clampOffset(Offset raw, Size area, EdgeInsets padding) {
    final minX = padding.left + Spacing.sm;
    final maxX = (area.width - padding.right - _pillWidth - Spacing.sm).clamp(minX, area.width);
    final minY = padding.top + Spacing.sm;
    final maxY = (area.height - padding.bottom - _pillHeight - Spacing.sm).clamp(minY, area.height);
    return Offset(raw.dx.clamp(minX, maxX), raw.dy.clamp(minY, maxY));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final area = Size(constraints.maxWidth, constraints.maxHeight);
        final padding = context.screenPadding;
        final current = _clampOffset(
          _offset ??
              Offset(
                area.width - padding.right - _pillWidth - Spacing.md,
                area.height - padding.bottom - _pillHeight - Spacing.xl,
              ),
          area,
          padding,
        );

        return Stack(
          children: [
            widget.child,
            if (!_isOnDevTools)
              Positioned(
                left: current.dx,
                top: current.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _offset = _clampOffset(current + details.delta, area, padding);
                    });
                  },
                  child: Material(
                    elevation: Elevations.level3,
                    borderRadius: BorderRadius.circular(Radii.full),
                    color: context.colors.primaryContainer,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(Radii.full),
                      onTap: () => unawaited(widget.router.push(AppRoutes.devTools)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                          vertical: Spacing.xs,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.developer_mode_rounded,
                              size: 16,
                              color: context.colors.onPrimaryContainer,
                            ),
                            const SizedBox(width: Spacing.xs),
                            Text(
                              AppInfo.devToolsBadge,
                              style: context.text.labelSmall?.copyWith(
                                color: context.colors.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
