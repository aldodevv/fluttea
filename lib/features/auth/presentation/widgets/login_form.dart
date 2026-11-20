import 'package:fluttea/core/constants/app/demo_credentials.dart';
import 'package:fluttea/core/constants/ui/radii.dart';
import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/errors/failure.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/widgets/buttons/app_button.dart';
import 'package:fluttea/core/widgets/feedback/app_snackbar.dart';
import 'package:fluttea/core/widgets/inputs/app_text_field.dart';
import 'package:fluttea/features/auth/state/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class LoginForm extends ConsumerStatefulWidget {
  const new({super.key, this.onSuccess});

  final VoidCallback? onSuccess;

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemo() {
    setState(() {
      _emailController.text = DemoCredentials.email;
      _passwordController.text = DemoCredentials.password;
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _errorMessage = null);

    final success = await ref
        .read(authNotifierProvider.notifier)
        .login(email: _emailController.text.trim(), password: _passwordController.text);

    if (!mounted) return;

    if (success) {
      AppSnackbar.show(context, context.l10n.authLoginSuccess);
      widget.onSuccess?.call();
    } else {
      final authState = ref.read(authNotifierProvider);
      setState(() {
        _errorMessage = switch (authState.error) {
          Failure(:final message) => message,
          _ => context.l10n.authLoginFailed,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: context.colors.errorContainer,
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: context.colors.onErrorContainer,
                    size: 20,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.md),
          ],
          AppTextField(
            controller: _emailController,
            label: context.l10n.authEmailLabel,
            hint: context.l10n.authEmailHint,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return context.l10n.authEmailRequired;
              }
              if (!value.contains('@') || !value.contains('.')) {
                return context.l10n.authEmailInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: Spacing.md),
          AppTextField(
            controller: _passwordController,
            label: context.l10n.authPasswordLabel,
            hint: context.l10n.authPasswordHint,
            isPassword: true,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.authPasswordRequired;
              }
              if (value.length < 6) {
                return context.l10n.authPasswordMinLength;
              }
              return null;
            },
          ),
          const SizedBox(height: Spacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _fillDemo,
              child: Text(
                context.l10n.authFillDemo,
                style: context.text.labelMedium?.copyWith(color: context.colors.primary),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          AppButton(
            label: context.l10n.authLoginButton,
            isFullWidth: true,
            isLoading: isLoading,
            onPressed: isLoading ? null : _submit,
          ),
        ],
      ),
    );
  }
}
