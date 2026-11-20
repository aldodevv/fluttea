import 'dart:async';

import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/errors/failure.dart';
import 'package:fluttea/core/widgets/buttons/app_button.dart';
import 'package:fluttea/core/widgets/feedback/app_snackbar.dart';
import 'package:fluttea/core/widgets/inputs/app_text_field.dart';
import 'package:fluttea/core/widgets/layout/section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class ProfileFormNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> updateProfile(String name) async {
    state = const AsyncLoading<void>();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (name.trim().length < 3) {
      state = const AsyncError<void>(
        ValidationFailure(message: 'Nama terlalu pendek (minimal 3 karakter).'),
        StackTrace.empty,
      );
      return false;
    }
    state = const AsyncData<void>(null);
    return true;
  }
}

final AsyncNotifierProvider<ProfileFormNotifier, void> profileFormProvider =
    AsyncNotifierProvider.autoDispose<ProfileFormNotifier, void>(ProfileFormNotifier.new);

class Case2FormMutationSection extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<Case2FormMutationSection> createState() => _Case2FormMutationSectionState();
}

class _Case2FormMutationSectionState extends ConsumerState<Case2FormMutationSection> {
  final TextEditingController _nameController = TextEditingController(text: 'Aldo Dev');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileFormAsync = ref.watch(profileFormProvider);

    return Section(
      title: '2. Form Mutation & Feedback',
      subtitle: 'Submit mutasi form dengan loading state terpadu',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                errorText: profileFormAsync.whenOrNull(
                  error: (e, _) => e is Failure ? e.message : e.toString(),
                ),
              ),
              const SizedBox(height: Spacing.md),
              AppButton(
                label: 'Simpan Profil',
                isFullWidth: true,
                isLoading: profileFormAsync.isLoading,
                onPressed: () async {
                  final ok = await ref
                      .read(profileFormProvider.notifier)
                      .updateProfile(_nameController.text);
                  if (ok && context.mounted) {
                    AppSnackbar.show(
                      context,
                      'Profil berhasil disimpan!',
                      variant: AppSnackbarVariant.success,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
