import 'dart:async';

import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/storage/prefs/preferences_storage.dart';
import 'package:fluttea/core/widgets/buttons/app_button.dart';
import 'package:fluttea/core/widgets/feedback/app_snackbar.dart';
import 'package:fluttea/core/widgets/states/empty_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class StorageTab extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<StorageTab> createState() => _StorageTabState();
}

class _StorageTabState extends ConsumerState<StorageTab> {
  final _prefs = PreferencesStorage();
  Map<String, String> _items = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadStorage());
  }

  Future<void> _loadStorage() async {
    setState(() => _isLoading = true);
    final keys = await _prefs.getKeys();
    final map = <String, String>{};

    for (final key in keys) {
      final str = await _prefs.getString(key);
      if (str != null) {
        map[key] = str;
      } else {
        final b = await _prefs.getBool(key);
        if (b != null) {
          map[key] = b.toString();
        } else {
          final i = await _prefs.getInt(key);
          map[key] = i?.toString() ?? '(binary/list)';
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _items = map;
      _isLoading = false;
    });
  }

  Future<void> _deleteKey(String key) async {
    await _prefs.remove(key);
    await _loadStorage();
    if (!mounted) return;
    AppSnackbar.show(context, 'Key "$key" dihapus');
  }

  Future<void> _clearAll() async {
    await _prefs.clear();
    await _loadStorage();
    if (!mounted) return;
    AppSnackbar.show(context, 'Seluruh Preferences dibersihkan');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Entries: ${_items.length}', style: context.text.titleSmall),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                    onPressed: () => unawaited(_loadStorage()),
                  ),
                  if (_items.isNotEmpty)
                    AppButton(
                      label: 'Clear All',
                      size: AppButtonSize.small,
                      variant: AppButtonVariant.outlined,
                      onPressed: () => unawaited(_clearAll()),
                    ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _items.isEmpty
              ? const EmptyView(
                  title: 'Preferences Kosong',
                  message: 'Belum ada data key-value yang tersimpan.',
                )
              : ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final key = _items.keys.elementAt(index);
                    final val = _items[key] ?? '';

                    return ListTile(
                      title: Text(key, style: context.text.labelLarge),
                      subtitle: Text(
                        val,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => unawaited(_deleteKey(key)),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
