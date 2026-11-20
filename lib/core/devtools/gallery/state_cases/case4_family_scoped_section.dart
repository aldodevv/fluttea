import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/widgets/layout/section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show NotifierProviderFamily;
import 'package:material_ui/material_ui.dart';

class ItemCounterNotifier extends Notifier<int> {
  new(this.arg);
  final String arg;

  @override
  int build() => 1;

  void increment() => state++;
  void decrement() {
    if (state > 1) state--;
  }
}

final NotifierProviderFamily<ItemCounterNotifier, int, String> itemCounterProvider =
    NotifierProvider.autoDispose.family<ItemCounterNotifier, int, String>(ItemCounterNotifier.new);

class Case4FamilyScopedSection extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const Section(
      title: '4. Scoped State via Family (.family)',
      subtitle: 'State counter terisolasi per item ID dan autoDispose',
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(Spacing.md),
          child: Column(
            children: [
              _FamilyCounterItem(itemId: 'item_a', itemName: 'Kopi Espresso'),
              Divider(),
              _FamilyCounterItem(itemId: 'item_b', itemName: 'Croissant Coklat'),
            ],
          ),
        ),
      ),
    );
  }
}

class _FamilyCounterItem extends ConsumerWidget {
  const new({required this.itemId, required this.itemName});
  final String itemId;
  final String itemName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(itemCounterProvider(itemId));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(itemName, style: context.text.bodyMedium),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => ref.read(itemCounterProvider(itemId).notifier).decrement(),
            ),
            Text('$count', style: context.text.titleMedium),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => ref.read(itemCounterProvider(itemId).notifier).increment(),
            ),
          ],
        ),
      ],
    );
  }
}
