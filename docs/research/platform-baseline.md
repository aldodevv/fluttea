# Platform Baseline

Diperiksa 2026-11-14.

| Item | Nilai | Sumber |
|---|---|---|
| Flutter stable terbaru | 3.50.0, Dart 3.14.0, rilis 2026-11-11 | `releases_macos.json` (storage.googleapis.com) |
| Flutter lokal | 3.47.9, Dart 3.13.7 (perlu upgrade) | `flutter --version` |
| SPM | Default sejak Flutter 3.44; fallback CocoaPods untuk plugin non-SPM | docs.flutter.dev/packages-and-plugins/swift-package-manager |
| Android target SDK | **API 36 (Android 16)** wajib untuk app baru dan update di Play sejak 2026-08-31 | developer.android.com/google/play/requirements/target-sdk |
| Android SDK lokal | platforms 31, 33, 34, 35, 36, 36.1 terpasang | `~/Library/Android/sdk/platforms` |
| JDK lokal | OpenJDK 21 | `java -version` |
| Xcode lokal | 27.2 | `xcodebuild -version` |
| Minimum Dart paket pilihan | riverpod ≥ 3.12, freezed ≥ 3.13, pigeon ≥ 3.11 | pub.dev |

## Aturan template
- `compileSdk`/`targetSdk` = 36 (atau lebih baru bila Flutter 3.50 mensyaratkan), `minSdk` dari keputusan user (usulan 26), Java 17 bytecode, Kotlin dan AGP sesuai template resmi Flutter 3.50 (jangan ditebak: ambil dari `flutter create` terbaru lalu cocokkan).
- `flutter create --platforms=android,ios --org <org> --project-name <name>`.
- iOS: tidak ada `Podfile` bila semua plugin SPM; bila ada plugin yang masih CocoaPods, catat di `dependency-log.md`.
- Wajib diperiksa saat build: edge-to-edge (Android 15+), predictive back, 16 KB page size untuk `.so`, `PrivacyInfo.xcprivacy`, ATS.
- Alat yang perlu dipasang: `osv-scanner`, `gitleaks` (belum ada), `semgrep` (opsional). Snyk lewat MCP.

## Hasil fase 1 (terverifikasi dengan build nyata, 2026-11-14)
- Flutter 3.50.0 via FVM, pin di `.fvmrc` project. `~/.fvmrc` (global home) tetap 3.47.9; **jangan** menjalankan `fvm use` dari luar folder project karena FVM menulis ke `~/.fvmrc`.
- Template 3.50: `compileSdk`=36, `targetSdk`=36, `flutter.minSdkVersion`=24 (diganti jadi **29**), Gradle 9.5.0, Kotlin plugin 2.4.20, Java 17, `sdk: ^3.14.0`. iOS default 15.0 (diganti jadi **16.0**).
- Alasan minSdk 29 / iOS 16: Android 10+ (TLS 1.3 platform, scoped storage, BiometricPrompt dan StrongBox sudah ada sejak 28) dan iOS 16+ (App Attest ≥ 14, sisa versi lama tidak lagi menerima patch). Ini keputusan keamanan, bukan data pangsa pasar: tinjau ulang bila bisnis butuh perangkat lama.
- **Material dan Cupertino sudah paket terpisah:** `material_ui` dan `cupertino_ui` (flutter.dev). `package:flutter/material.dart` deprecated sejak 3.47.
- SPM: config global mesin ini mematikan SPM (`~/.config/flutter/settings`: `enable-swift-package-manager: false`). Project mengaktifkannya sendiri lewat `pubspec.yaml` → `flutter: config: enable-swift-package-manager: true` (cara resmi per-project). Hasil: build iOS tanpa Podfile/Pods.
- Flavor dibuat sekali dengan flutter_flavorizr 2.6.0: Android `productFlavors dev/prod` (`com.fluttea.fluttea.dev` / `com.fluttea.fluttea`, label "Fluttea Dev" / "Fluttea"), iOS 9 build configuration + scheme `dev` dan `prod`. Ikon per flavor belum dibuat (dev dan prod memakai ikon yang sama).
- Masalah lingkungan: `xcrun` default ke `ixguard.xctoolchain`; set `TOOLCHAINS=com.apple.dt.toolchain.XcodeDefault` agar `flutter test`/build native assets jalan.
- Peringatan build: plugin yang masih memakai KGP akan gagal di Flutter mendatang (kena pada `cryptography_flutter` → dikeluarkan). Periksa tiap plugin baru dengan build Android.
- Peringatan build release: "ELF library contains unobfuscated DWARF debugging information" meski `--obfuscate --split-debug-info` dipakai; opsi `--strip` belum terdaftar di `flutter build apk --help`. Selidiki di fase 9 (hardening) sebelum rilis.
- Hasil pindai: `dart analyze` 0 issue, `gitleaks` 0 temuan, `osv-scanner` 0 advisory pada 153 paket di `pubspec.lock`. Ukuran APK release prod universal: 45,6 MB (skeleton, 3 ABI).
