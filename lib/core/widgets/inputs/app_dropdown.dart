import 'package:material_ui/material_ui.dart';

class AppDropdown<T> extends StatelessWidget {
  const new({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.label,
    this.hint,
    this.validator,
    this.enabled = true,
  });

  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final String? label;
  final String? hint;
  final FormFieldValidator<T>? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      items: items,
      onChanged: enabled ? onChanged : null,
      initialValue: value,
      validator: validator,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}
