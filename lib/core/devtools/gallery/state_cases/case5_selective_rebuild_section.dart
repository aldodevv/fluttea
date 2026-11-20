import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/widgets/buttons/app_button.dart';
import 'package:fluttea/core/widgets/layout/section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

@immutable
class DashboardData {
  const new({required this.userTitle, required this.notifCount});

  final String userTitle;
  final int notifCount;

  DashboardData copyWith({String? userTitle, int? notifCount}) => DashboardData(
    userTitle: userTitle ?? this.userTitle,
    notifCount: notifCount ?? this.notifCount,
  );
}

class DashboardNotifier extends Notifier<DashboardData> {
  @override
  DashboardData build() => const DashboardData(userTitle: 'Developer', notifCount: 3);

  void changeTitle(String newTitle) => state = state.copyWith(userTitle: newTitle);
  void incrementNotif() => state = state.copyWith(notifCount: state.notifCount + 1);
}

final NotifierProvider<DashboardNotifier, DashboardData> dashboardProvider =
    NotifierProvider<DashboardNotifier, DashboardData>(DashboardNotifier.new);

class Case5SelectiveRebuildSection extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Section(
      title: '5. Selective Rebuilding (.select)',
      subtitle: 'Hanya widget terkait yang rebuild saat sub-state berubah',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            children: [
              const _SelectiveTitleDisplay(),
              const SizedBox(height: Spacing.xs),
              const _SelectiveNotifDisplay(),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Ubah Judul',
                      size: AppButtonSize.small,
                      variant: AppButtonVariant.tonal,
                      onPressed: () {
                        final current = ref.read(dashboardProvider).userTitle;
                        ref
                            .read(dashboardProvider.notifier)
                            .changeTitle(current == 'Developer' ? 'Tech Lead' : 'Developer');
                      },
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: AppButton(
                      label: 'Tambah Notifikasi',
                      size: AppButtonSize.small,
                      variant: AppButtonVariant.tonal,
                      onPressed: () => ref.read(dashboardProvider.notifier).incrementNotif(),
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

class _SelectiveTitleDisplay extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTitle = ref.watch(dashboardProvider.select((d) => d.userTitle));
    return Row(
      children: [
        const Icon(Icons.badge_outlined, size: 20),
        const SizedBox(width: Spacing.xs),
        Text('Judul (selected): $userTitle', style: context.text.bodyMedium),
      ],
    );
  }
}

class _SelectiveNotifDisplay extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifCount = ref.watch(dashboardProvider.select((d) => d.notifCount));
    return Row(
      children: [
        const Icon(Icons.notifications_none, size: 20),
        const SizedBox(width: Spacing.xs),
        Text('Notifikasi (selected): $notifCount', style: context.text.bodyMedium),
      ],
    );
  }
}
