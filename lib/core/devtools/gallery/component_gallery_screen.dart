import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/widgets/buttons/app_button.dart';
import 'package:fluttea/core/widgets/feedback/app_bottom_sheet.dart';
import 'package:fluttea/core/widgets/feedback/app_dialog.dart';
import 'package:fluttea/core/widgets/feedback/app_snackbar.dart';
import 'package:fluttea/core/widgets/inputs/app_dropdown.dart';
import 'package:fluttea/core/widgets/inputs/app_text_field.dart';
import 'package:fluttea/core/widgets/inputs/otp_field.dart';
import 'package:fluttea/core/widgets/inputs/search_field.dart';
import 'package:fluttea/core/widgets/layout/app_scaffold.dart';
import 'package:fluttea/core/widgets/layout/section.dart';
import 'package:fluttea/core/widgets/loading/app_loader.dart';
import 'package:fluttea/core/widgets/loading/skeleton.dart';
import 'package:fluttea/core/widgets/media/app_avatar.dart';
import 'package:fluttea/core/widgets/states/empty_view.dart';
import 'package:fluttea/core/widgets/states/error_view.dart';
import 'package:fluttea/core/widgets/states/offline_banner.dart';
import 'package:material_ui/material_ui.dart';

class ComponentGalleryScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Komponen UI Gallery')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OfflineBanner(),
            const SizedBox(height: Spacing.md),

            Section(
              title: 'Buttons (Variants & States)',
              child: Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.sm,
                children: [
                  AppButton(label: 'Filled', onPressed: () {}),
                  AppButton(label: 'Tonal', variant: AppButtonVariant.tonal, onPressed: () {}),
                  AppButton(
                    label: 'Outlined',
                    variant: AppButtonVariant.outlined,
                    onPressed: () {},
                  ),
                  AppButton(label: 'Text', variant: AppButtonVariant.text, onPressed: () {}),
                  AppButton(label: 'Loading', isLoading: true, onPressed: () {}),
                ],
              ),
            ),
            const SizedBox(height: Spacing.lg),

            Section(
              title: 'Inputs',
              child: Column(
                children: [
                  const AppTextField(
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama Anda',
                    prefixIcon: Icon(Icons.person),
                  ),
                  const SizedBox(height: Spacing.md),
                  const AppTextField(
                    label: 'Kata Sandi',
                    isPassword: true,
                    prefixIcon: Icon(Icons.lock),
                  ),
                  const SizedBox(height: Spacing.md),
                  AppDropdown<String>(
                    label: 'Peran',
                    value: 'admin',
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(value: 'member', child: Text('Member')),
                    ],
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: Spacing.md),
                  SearchField(onSearch: (_) {}),
                  const SizedBox(height: Spacing.md),
                  OtpField(onCompleted: (_) {}),
                ],
              ),
            ),
            const SizedBox(height: Spacing.lg),

            Section(
              title: 'Feedback (Snackbar, Dialog, Sheet)',
              child: Wrap(
                spacing: Spacing.sm,
                children: [
                  AppButton(
                    label: 'Show Snackbar',
                    variant: AppButtonVariant.outlined,
                    onPressed: () => AppSnackbar.show(
                      context,
                      'Operasi berhasil dilakukan!',
                      variant: AppSnackbarVariant.success,
                    ),
                  ),
                  AppButton(
                    label: 'Show Dialog',
                    variant: AppButtonVariant.outlined,
                    onPressed: () => AppDialog.show(
                      context,
                      title: 'Konfirmasi',
                      message: 'Apakah Anda yakin ingin melanjutkan?',
                      cancelLabel: 'Batal',
                    ),
                  ),
                  AppButton(
                    label: 'Show BottomSheet',
                    variant: AppButtonVariant.outlined,
                    onPressed: () => AppBottomSheet.show<void>(
                      context,
                      title: 'Pilihan Tindakan',
                      child: Text('Isi bottom sheet', style: context.text.bodyMedium),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.lg),

            const Section(
              title: 'Loading & Skeletons',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppLoader(message: 'Memuat data...'),
                  SizedBox(height: Spacing.md),
                  Skeleton(height: 20),
                  SizedBox(height: Spacing.xs),
                  Skeleton(height: 14, width: 200),
                ],
              ),
            ),
            const SizedBox(height: Spacing.lg),

            const Section(
              title: 'Avatars',
              child: Row(
                children: [
                  AppAvatar(name: 'Aldo Developer'),
                  SizedBox(width: Spacing.md),
                  AppAvatar(name: 'Budi Santoso', radius: 32),
                ],
              ),
            ),
            const SizedBox(height: Spacing.lg),

            Section(
              title: 'State Views (Empty & Error)',
              child: Column(
                children: [
                  EmptyView(
                    title: 'Belum Ada Transaksi',
                    message: 'Transaksi Anda akan tampil di sini.',
                    actionLabel: 'Mulai Transaksi',
                    onAction: () {},
                  ),
                  const SizedBox(height: Spacing.md),
                  ErrorView(message: 'Gagal terhubung ke server', onRetry: () {}),
                ],
              ),
            ),
            const SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }
}
