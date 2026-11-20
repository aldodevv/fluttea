import 'dart:async';

import 'package:fluttea/app/router/routes.dart';
import 'package:fluttea/core/constants/app/app_info.dart';
import 'package:fluttea/core/constants/ui/elevations.dart';
import 'package:fluttea/core/constants/ui/radii.dart';
import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
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

  Offset _clampOffset(Offset raw, Size area, EdgeInsets padding) {
    final minX = padding.left + Spacing.sm;
    final maxX = (area.width - padding.right - _pillWidth - Spacing.sm).clamp(minX, area.width);
    final minY = padding.top + Spacing.sm;
    final maxY = (area.height - padding.bottom - _pillHeight - Spacing.sm).clamp(minY, area.height);
    return Offset(raw.dx.clamp(minX, maxX), raw.dy.clamp(minY, maxY));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.router.routeInformationProvider,
      builder: (context, _) {
        final currentPath = widget.router.routeInformationProvider.value.uri.path;
        final isOnDevTools = currentPath.startsWith(AppRoutes.devTools);
        if (isOnDevTools) return widget.child;

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
      },
    );
  }
}
