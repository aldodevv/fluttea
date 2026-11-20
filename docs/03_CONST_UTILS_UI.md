# 03 — Const, Utils, Theme, Widget

## 1. `core/constants/` — hanya `const`
Tanpa logika, tanpa import Flutter UI kecuali tipe primitif yang dibutuhkan (`Duration`, `Color` untuk token mentah hanya di `ui/`). Satu file satu topik, dibungkus `abstract final class` agar tidak bisa di-instantiate.

```
constants/
├─ api/
│  ├─ api_paths.dart          # ApiPaths.login, ApiPaths.profile
│  ├─ api_hosts.dart          # ApiHosts.devDefault, ApiHosts.prodDefault (public, bukan rahasia)
│  └─ api_headers.dart        # nama header: ApiHeaders.authorization, .deviceId, .requestId
├─ response/
│  ├─ error_codes.dart        # ErrorCodes.network, .timeout, .unauthorized, .server, .parse, .pinning, .tampered
│  ├─ success_codes.dart      # SuccessCodes.ok, .created
│  └─ http_status.dart
├─ ui/
│  ├─ spacing.dart            # Spacing.xs/sm/md/lg/xl
│  ├─ radii.dart  durations.dart  elevations.dart  icon_sizes.dart  breakpoints.dart
│  └─ palette.dart            # warna mentah brand (hanya dibaca oleh core/theme)
├─ roles/
│  └─ user_roles.dart         # UserRoles.admin, .member, .guest
├─ remote_config/
│  └─ rc_keys.dart            # RcKeys.maintenance, .minVersion
├─ storage/
│  └─ storage_keys.dart       # StorageKeys.accessToken, .locale
├─ security/
│  └─ security_consts.dart    # nama algoritma, panjang key/nonce, iterasi KDF
├─ app/
│  ├─ app_info.dart           # nama, bundle id, scheme
│  └─ locale_codes.dart
├─ asset_paths.dart           # AssetPaths.logo (string path), diurutkan per folder
└─ regex.dart                 # pola validasi
```
Aturan: tidak ada angka/string literal bermakna di luar folder ini (timeout, durasi animasi, jarak, key storage, path API, kode error).

## 2. `core/utils/` — fungsi murni, per topik
```
utils/
├─ ui/          # responsive.dart, keyboard.dart, snackbar_helper.dart, haptics.dart
├─ network/     # url_builder.dart, query_encoder.dart, connectivity_utils.dart
├─ date/        # date_format.dart, time_zone.dart
├─ string/      # masking.dart, validators.dart, formatters.dart
├─ number/      # currency.dart
├─ file/        # file_picker_utils.dart, mime.dart
├─ platform/    # platform_info.dart
└─ debounce.dart  throttle.dart
```
Util tidak menyimpan state, tidak memanggil `Navigator`/`BuildContext` kecuali di `utils/ui/`. Bila perlu state → jadi service di `core/services/`.

## 3. Theme (`core/theme/`)
```
theme/
├─ app_theme.dart         # AppTheme.light(), AppTheme.dark() → ThemeData (useMaterial3)
├─ color_scheme.dart      # ColorScheme.fromSeed / manual dari palette
├─ text_theme.dart
├─ component_themes/      # button_theme.dart, input_theme.dart, card_theme.dart, dialog_theme.dart, appbar_theme.dart ...
└─ extensions/            # AppColors, AppSpacing, AppStatusColors sebagai ThemeExtension
```
- Semua komponen dikonfigurasi di `component_themes/` (ElevatedButtonTheme, InputDecorationTheme, dst.). Widget feature **tidak** menetapkan style bila default sudah cocok.
- Token kustom di luar `ColorScheme` (success, warning, info) memakai `ThemeExtension<T>` dengan `copyWith` dan `lerp`.
- Akses via extension: `context.colors`, `context.text`, `context.spacing`.
- Dark mode, text scale, dan RTL tidak boleh rusak. Diuji dengan golden/test widget sederhana.
- Import `package:material_ui/material_ui.dart` (bukan `flutter/material.dart`, deprecated sejak Flutter 3.47). Verifikasi API `ThemeData`/Material 3 via Context7 sebelum menulis (beberapa `*ThemeData` vs `*Theme` berubah antar versi).

## 4. Widget
### Global — `core/widgets/` (dikelompokkan per jenis)
```
widgets/
├─ buttons/   app_button.dart (variant: filled/tonal/outlined/text)
├─ inputs/    app_text_field.dart, app_dropdown.dart, otp_field.dart, search_field.dart
├─ feedback/  app_snackbar.dart, app_dialog.dart, app_bottom_sheet.dart, app_toast.dart
├─ loading/   app_loader.dart, skeleton.dart
├─ states/    empty_view.dart, error_view.dart, offline_banner.dart
├─ layout/    app_scaffold.dart, section.dart, responsive_builder.dart, keyboard_dismiss.dart
├─ media/     app_image.dart (network + placeholder + error), app_avatar.dart
├─ lists/     paged_list.dart, refresh_list.dart
└─ security/  secure_screen.dart (FLAG_SECURE / blur saat background), privacy_overlay.dart
```
Kontrak widget global:
- **Default dari theme.** Konstruktor menerima parameter opsional untuk override (`style`, `padding`, `color`, `shape`); `null` berarti pakai theme. Tidak ada parameter wajib yang sebenarnya default.
- Satu widget = satu file. Parameter `Key? key` via `super.key`. `const` constructor bila mungkin.
- Teks datang dari parameter/l10n, bukan di-hardcode.
- Aksesibilitas: `Semantics`, target sentuh ≥ 48dp, kontras cukup, tidak bergantung warna saja.

### Lokal — `features/<f>/presentation/widgets/`
- Boleh menyesuaikan desain khusus fitur, tetap berbasis widget global + theme.
- Dipromosikan ke global bila dipakai ≥ 2 fitur.

### Screen
- Screen hanya menyusun widget dan membaca state; tidak memanggil Dio/repository langsung.
- Pola dasar screen: `AppScaffold` + `AsyncView` di atas `AsyncValue` (lihat 05) yang menangani loading/empty/error/data seragam.
- Detail desain screen mengikuti kebutuhan project (di luar template).

## 5. Lint pendukung
`avoid_hardcoded_colors` tidak ada di lint standar; tambahkan `tool/check_ui_rules.sh` (grep `Colors\.`, `Color(0x`, `fontSize:`, `EdgeInsets.*\d` di `lib/features`) dan jalankan di CI.
