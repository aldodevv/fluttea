import 'package:fluttea/core/extensions/context_x.dart';
import 'package:material_ui/material_ui.dart';

class AppTextField extends StatefulWidget {
  const new({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final int maxLines;
  final bool autofocus;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    var effectiveSuffix = widget.suffixIcon;

    if (widget.isPassword) {
      effectiveSuffix = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: context.colors.onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      validator: widget.validator,
      enabled: widget.enabled,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: effectiveSuffix,
      ),
    );
  }
}
