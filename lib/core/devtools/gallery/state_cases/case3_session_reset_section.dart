import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/state/lifecycle_provider.dart';
import 'package:fluttea/core/state/reset_policy.dart';
import 'package:fluttea/core/state/session_state_provider.dart';
import 'package:fluttea/core/widgets/buttons/app_button.dart';
import 'package:fluttea/core/widgets/layout/section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class CartNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    ref.resetOn({ResetOn.logout, ResetOn.backgroundFor(const Duration(minutes: 5))});
    return [];
  }

  void addItem(String item) {
    state = [...state, item];
  }

  void clear() {
    state = [];
  }
}

final NotifierProvider<CartNotifier, List<String>> cartProvider =
    NotifierProvider<CartNotifier, List<String>>(CartNotifier.new);

class Case3SessionResetSection extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final session = ref.watch(sessionProvider);

    return Section(
      title: '3. Session State & resetOn (Logout / Background)',
      subtitle: 'State Cart otomatis reset saat logout atau background timeout',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status Sesi: ${session.isAuthenticated ? "Login (${(session as AuthenticatedSession).userId})" : "Belum Login"}',
                style: context.text.titleSmall,
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                'Isi Cart (${cartItems.length} item): ${cartItems.isEmpty ? "Kosong" : cartItems.join(", ")}',
              ),
              const SizedBox(height: Spacing.md),
              Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.sm,
                children: [
                  if (!session.isAuthenticated)
                    AppButton(
                      label: 'Simulasi Login',
                      size: AppButtonSize.small,
                      onPressed: () => ref
                          .read(sessionProvider.notifier)
                          .login(userId: 'user_001', token: 'sample_token_xyz'),
                    )
                  else
                    AppButton(
                      label: 'Simulasi Logout (Trigger Reset)',
                      size: AppButtonSize.small,
                      variant: AppButtonVariant.outlined,
                      onPressed: () => ref.read(sessionProvider.notifier).logout(),
                    ),
                  AppButton(
                    label: 'Simulasi 6 Menit Background (Trigger Reset)',
                    size: AppButtonSize.small,
                    variant: AppButtonVariant.outlined,
                    onPressed: () => ref
                        .read(appLifecycleProvider.notifier)
                        .updateState(
                          AppLifecycleState.resumed,
                          backgroundDuration: const Duration(minutes: 6),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
