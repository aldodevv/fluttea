import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/widgets/loading/app_loader.dart';
import 'package:material_ui/material_ui.dart';

class PagedList<T> extends StatefulWidget {
  const new({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.separatorBuilder,
    this.padding,
    this.emptyWidget,
    this.scrollThreshold = 200.0,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;
  final IndexedWidgetBuilder? separatorBuilder;
  final EdgeInsetsGeometry? padding;
  final Widget? emptyWidget;
  final double scrollThreshold;

  @override
  State<PagedList<T>> createState() => _PagedListState<T>();
}

class _PagedListState<T> extends State<PagedList<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoadingMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= widget.scrollThreshold) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    final totalCount = widget.items.length + (widget.hasMore ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: Spacing.md),
            child: AppLoader(size: 24),
          );
        }
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }
}
