import 'package:fluttea/core/errors/failure.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/widgets/loading/app_loader.dart';
import 'package:fluttea/core/widgets/states/empty_view.dart';
import 'package:fluttea/core/widgets/states/error_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class AsyncView<T> extends StatelessWidget {
  const new({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.empty,
    this.isEmpty,
    this.onRetry,
    this.onRefresh,
    this.showLoadingOnRefresh = false,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final WidgetBuilder? loading;
  final Widget Function(Object error, StackTrace stackTrace)? error;
  final WidgetBuilder? empty;
  final bool Function(T data)? isEmpty;
  final VoidCallback? onRetry;
  final RefreshCallback? onRefresh;
  final bool showLoadingOnRefresh;

  @override
  Widget build(BuildContext context) {
    // Jika sedang refresh dan sudah ada data sebelumnya (kecuali showLoadingOnRefresh diminta)
    if (!showLoadingOnRefresh && value.isRefreshing && value.hasValue) {
      return _buildDataView(context, value.requireValue);
    }

    return value.when(
      skipLoadingOnRefresh: !showLoadingOnRefresh,
      data: (d) {
        if (isEmpty != null && isEmpty!(d)) {
          return empty != null
              ? empty!(context)
              : EmptyView(title: context.l10n.emptyTitle, message: context.l10n.emptyMessage);
        }
        return _buildDataView(context, d);
      },
      loading: () => loading != null ? loading!(context) : AppLoader(message: context.l10n.loading),
      error: (err, stack) {
        if (error != null) {
          return error!(err, stack);
        }

        final message = err is Failure ? err.message : context.l10n.errorGeneric;

        return ErrorView(message: message, onRetry: onRetry);
      },
    );
  }

  Widget _buildDataView(BuildContext context, T d) {
    final content = data(d);
    if (onRefresh != null) {
      return RefreshIndicator(onRefresh: onRefresh!, child: content);
    }
    return content;
  }
}
