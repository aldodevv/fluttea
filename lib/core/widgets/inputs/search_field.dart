import 'package:fluttea/core/constants/ui/durations.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/utils/debounce.dart';
import 'package:material_ui/material_ui.dart';

class SearchField extends StatefulWidget {
  const new({
    super.key,
    required this.onSearch,
    this.hint,
    this.debounceDelay = AppDurations.debounce,
  });

  final String? hint;
  final ValueChanged<String> onSearch;
  final Duration debounceDelay;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();
  late final Debouncer _debouncer = Debouncer(delay: widget.debounceDelay);

  @override
  void dispose() {
    _controller.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debouncer.run(() => widget.onSearch(query));
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      decoration: InputDecoration(
        hintText: widget.hint ?? context.l10n.searchHint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(icon: const Icon(Icons.clear), onPressed: _clear)
            : null,
      ),
      style: context.text.bodyMedium,
    );
  }
}
