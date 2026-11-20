import 'package:fluttea/core/constants/ui/radii.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:material_ui/material_ui.dart';

class Skeleton extends StatefulWidget {
  const new({
    super.key,
    this.width,
    this.height = 16.0,
    this.borderRadius = Radii.sm,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.25,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.circle
                ? null
                : BorderRadius.circular(widget.borderRadius),
            color: context.colors.surfaceContainerHighest.withValues(alpha: _animation.value),
          ),
        );
      },
    );
  }
}
