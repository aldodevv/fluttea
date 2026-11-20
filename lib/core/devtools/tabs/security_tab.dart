import 'package:fluttea/app/router/routes.dart';
import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/security/rasp/security_policy.dart';
import 'package:fluttea/core/security/rasp/security_signals.dart';
import 'package:fluttea/core/security/rasp/security_verdict.dart';
import 'package:fluttea/core/widgets/buttons/app_button.dart';
import 'package:fluttea/core/widgets/layout/section.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class SecurityTab extends StatefulWidget {
  const new({super.key});

  @override
  State<SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends State<SecurityTab> {
  bool _isRooted = false;
  bool _isEmulator = false;
  bool _isDebugger = false;
  bool _isTampered = false;
  bool _hasProxy = false;
  bool _isProdPolicy = true;

  SecurityVerdict _computeVerdict() {
    final signals = SecuritySignals(
      isRootedOrJailbroken: _isRooted,
      isEmulator: _isEmulator,
      isDebuggerAttached: _isDebugger,
      isTampered: _isTampered,
      hasProxyConfigured: _hasProxy,
    );
    final policy = _isProdPolicy ? SecurityPolicy.prod() : SecurityPolicy.dev();
    return policy.evaluate(signals);
  }

  @override
  Widget build(BuildContext context) {
    final verdict = _computeVerdict();
    final verdictColor = switch (verdict) {
      SecurityVerdictAllow() => context.statusColors.success,
      SecurityVerdictWarn() => context.statusColors.warning,
      SecurityVerdictRestrict() ||
      SecurityVerdictBlock() ||
      SecurityVerdictWipe() => context.colors.error,
    };

    return ListView(
      padding: const EdgeInsets.all(Spacing.md),
      children: [
        Section(
          title: 'Current Gate Verdict',
          child: Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: verdictColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Spacing.sm),
              border: Border.all(color: verdictColor),
            ),
            child: Row(
              children: [
                Icon(
                  verdict.isAllowed ? Icons.shield_outlined : Icons.warning_amber_rounded,
                  color: verdictColor,
                  size: 28,
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        verdict.runtimeType.toString().replaceFirst('SecurityVerdict', ''),
                        style: context.text.titleSmall?.copyWith(
                          color: verdictColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(verdict.toString(), style: context.text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.lg),
        Section(
          title: 'RASP Signal Simulator',
          subtitle: 'Simulasikan ancaman lingkungan untuk menguji respon aplikasi',
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Enforce Prod Policy (Strict)'),
                subtitle: Text(_isProdPolicy ? 'Prod: Block on Root/Tamper' : 'Dev: Warn only'),
                value: _isProdPolicy,
                onChanged: (v) => setState(() => _isProdPolicy = v),
              ),
              const Divider(),
              CheckboxListTile(
                title: const Text('Root / Jailbreak'),
                value: _isRooted,
                onChanged: (v) => setState(() => _isRooted = v ?? false),
              ),
              CheckboxListTile(
                title: const Text('Emulator / Simulator'),
                value: _isEmulator,
                onChanged: (v) => setState(() => _isEmulator = v ?? false),
              ),
              CheckboxListTile(
                title: const Text('Debugger Attached'),
                value: _isDebugger,
                onChanged: (v) => setState(() => _isDebugger = v ?? false),
              ),
              CheckboxListTile(
                title: const Text('Tampered Binary'),
                value: _isTampered,
                onChanged: (v) => setState(() => _isTampered = v ?? false),
              ),
              CheckboxListTile(
                title: const Text('Network Proxy Active'),
                value: _hasProxy,
                onChanged: (v) => setState(() => _hasProxy = v ?? false),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.lg),
        AppButton(
          label: 'Buka Security Showcase Lengkap',
          variant: AppButtonVariant.outlined,
          onPressed: () => context.push(AppRoutes.securityExamples),
        ),
      ],
    );
  }
}
