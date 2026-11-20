import 'package:fluttea/core/constants/ui/radii.dart';
import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

class OtpField extends StatefulWidget {
  const new({super.key, required this.onCompleted, this.length = 6, this.onChanged});

  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index + 1 < widget.length) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    final code = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(code);

    if (code.length == widget.length) {
      widget.onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return Container(
          width: 44,
          height: 52,
          margin: const EdgeInsets.symmetric(horizontal: Spacing.xs),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: context.text.titleLarge,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.md)),
            ),
            onChanged: (val) => _onDigitChanged(index, val),
          ),
        );
      }),
    );
  }
}
