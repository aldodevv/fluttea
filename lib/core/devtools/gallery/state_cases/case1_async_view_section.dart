import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/devtools/gallery/state_cases/case3_session_reset_section.dart';
import 'package:fluttea/core/errors/failure.dart';
import 'package:fluttea/core/state/async_view.dart';
import 'package:fluttea/core/widgets/buttons/app_button.dart';
import 'package:fluttea/core/widgets/layout/section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class ProductListNotifier extends AsyncNotifier<List<String>> {
  bool simulateError = false;
  String query = '';

  @override
  Future<List<String>> build() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (simulateError) {
      throw const NetworkFailure(message: 'Simulasi kegagalan jaringan saat mengambil produk.');
    }
    const mockProducts = ['Laptop Pro', 'Smartphone 5G', 'Wireless Earbuds', 'Mechanical Keyboard'];
    if (query.isEmpty) return mockProducts;
    return mockProducts.where((p) => p.toLowerCase().contains(query.toLowerCase())).toList();
  }

  void search(String newQuery) {
    query = newQuery;
    ref.invalidateSelf();
  }

  void toggleError(bool hasError) {
    simulateError = hasError;
    ref.invalidateSelf();
  }
}

final AsyncNotifierProvider<ProductListNotifier, List<String>> productListProvider =
    AsyncNotifierProvider.autoDispose<ProductListNotifier, List<String>>(ProductListNotifier.new);

class Case1AsyncViewSection extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<Case1AsyncViewSection> createState() => _Case1AsyncViewSectionState();
}

class _Case1AsyncViewSectionState extends ConsumerState<Case1AsyncViewSection> {
  bool _errorSimulated = false;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);

    return Section(
      title: '1. AsyncView (Data / Empty / Error / Loading)',
      subtitle: 'Penanganan async seragam dengan retry & refresh',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: _errorSimulated ? 'Hentikan Error' : 'Simulasi Error',
                      variant: AppButtonVariant.outlined,
                      onPressed: () {
                        setState(() {
                          _errorSimulated = !_errorSimulated;
                        });
                        ref.read(productListProvider.notifier).toggleError(_errorSimulated);
                      },
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: AppButton(
                      label: 'Set Filter Kosong',
                      variant: AppButtonVariant.outlined,
                      onPressed: () =>
                          ref.read(productListProvider.notifier).search('non-existing-xyz'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              AsyncView<List<String>>(
                value: productsAsync,
                isEmpty: (list) => list.isEmpty,
                onRetry: () {
                  setState(() {
                    _errorSimulated = false;
                  });
                  ref.read(productListProvider.notifier).toggleError(false);
                },
                onRefresh: () => ref.refresh(productListProvider.future),
                data: (products) => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = products[index];
                    return ListTile(
                      title: Text(item),
                      trailing: AppButton(
                        label: 'Tambah',
                        size: AppButtonSize.small,
                        variant: AppButtonVariant.tonal,
                        onPressed: () => ref.read(cartProvider.notifier).addItem(item),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
