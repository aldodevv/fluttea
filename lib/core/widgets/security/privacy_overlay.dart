import 'dart:ui';

import 'package:fluttea/core/extensions/context_x.dart';
import 'package:material_ui/material_ui.dart';

class PrivacyOverlay extends StatefulWidget {
  const new({super.key, required this.child, this.blurSigma = 16.0, this.message});

  final Widget child;
  final double blurSigma;
  final String? message;

  @override
  State<PrivacyOverlay> createState() => _PrivacyOverlayState();
}

class _PrivacyOverlayState extends State<PrivacyOverlay> with WidgetsBindingObserver {
  bool _isObscured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final shouldObscure =
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden;

    if (_isObscured != shouldObscure) {
      setState(() {
        _isObscured = shouldObscure;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isObscured)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: widget.blurSigma, sigmaY: widget.blurSigma),
              child: ColoredBox(
                color: context.colors.surface.withValues(alpha: 0.8),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_outlined, size: 48, color: context.colors.primary),
                        const SizedBox(height: 12),
                        Text(
                          widget.message ?? context.l10n.privacyProtected,
                          style: context.text.titleMedium?.copyWith(
                            color: context.colors.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
