import 'package:fluttea/core/extensions/context_x.dart';
import 'package:material_ui/material_ui.dart';

class RefreshList extends StatelessWidget {
  const new({
    super.key,
    required this.onRefresh,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    this.padding,
    this.emptyWidget,
  });

  final RefreshCallback onRefresh;
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final EdgeInsetsGeometry? padding;
  final Widget? emptyWidget;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0 && emptyWidget != null) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: context.colors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: emptyWidget,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: context.colors.primary,
      child: separatorBuilder != null
          ? ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: padding,
              itemCount: itemCount,
              itemBuilder: itemBuilder,
              separatorBuilder: separatorBuilder!,
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: padding,
              itemCount: itemCount,
              itemBuilder: itemBuilder,
            ),
    );
  }
}
