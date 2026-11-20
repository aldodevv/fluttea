# AGENTS.md — Fluttea (Flutter App Template)

Template Flutter yang compact, aman, dan rapi. Dipakai sebagai titik awal semua project. Kamu (AI agent) bertugas me-research, membangun, dan menjaga standar ini.

## Baca dulu (urut)
1. `docs/00_LESSONS_FROM_NYX.md` — kesalahan yang tidak boleh diulang
2. `docs/01_RESEARCH_PROTOCOL.md` — cara memilih dependency, platform terbaru, audit vulnerability
3. `docs/02_STRUCTURE.md` — struktur folder + aturan penamaan
0. `docs/research/00_REVIEW.md` — keputusan hasil riset (baca pertama)
4. `docs/03_CONST_UTILS_UI.md` — const, utils, theme, widget global/local
5. `docs/04_NETWORK.md` — Dio sebagai wrapper "lego"
6. `docs/05_STATE.md` — state management tanpa package
7. `docs/06_SECURITY.md` — crypto, pinning, RASP, file checker, supply chain
8. `docs/07_FLAVOR_QUALITY.md` — flavor dev/prod, testing, CI, tambahan best practice
9. `docs/08_BUILD_PLAN.md` — fase kerja + definition of done

## Aturan keras
- Library/SDK: **query Context7 MCP dulu**, jangan mengarang API. Versi diambil dari pub.dev, bukan ingatan.
- Tambah/hapus dependency = wajib lewat `docs/01_RESEARCH_PROTOCOL.md` + catat di `docs/research/dependency-log.md`.
- UI import `package:material_ui/material_ui.dart` (Flutter 3.50: `package:flutter/material.dart` deprecated). Bukan `flutter/material.dart`.
- Konstruktor memakai sintaks Dart 3.14 `const new(...)` (lint `unnecessary_type_name_in_constructor`); jalankan `dart fix --apply`.
- Satu konsep = satu tempat. Dilarang suffix `_v2`, `_new`, `_old`, `_copy` di nama folder/file/class.
- Const hanya di `core/constants/`, tidak ada magic string/number/warna di luar itu.
- Semua UI memakai `Theme.of(context)` / ThemeExtension. Dilarang `Colors.xxx`, `Color(0x..)`, `TextStyle(fontSize:..)`, `EdgeInsets` angka mentah di feature.
- API call tidak melempar exception ke UI; repository mengembalikan `Result<T>` (sealed class buatan sendiri), notifier mengubahnya ke `AsyncValue`.
- State/DI = Riverpod tanpa codegen. Codegen hanya `freezed` + `json_serializable` (build_runner).
- Hasil riset dan keputusan: `docs/research/00_REVIEW.md`. Dokumen di `docs/` yang bertentangan dengan `docs/research/` kalah.
- Rahasia tidak boleh masuk bundle (`.env` sebagai asset dilarang).
- File > 300 baris = pecah. Satu file satu tanggung jawab.
- Tanpa komentar basa-basi. Hanya komentar untuk keputusan non-obvious.
- Jangan edit file generated (`*.g.dart`, `*.gen.dart`).

## Perintah (selalu prefix `rtk`, Flutter lewat FVM: `fvm flutter`, pin di `.fvmrc` = 3.50.0)
Catatan lingkungan (mesin dev ini): `xcrun` memilih `~/Library/Developer/Toolchains/ixguard.xctoolchain` sebagai clang default dan membuat `flutter test`/build gagal di langkah native assets. Jalankan dengan `export TOOLCHAINS=com.apple.dt.toolchain.XcodeDefault`.
```bash
rtk fvm flutter pub get
rtk fvm dart run build_runner build --delete-conflicting-outputs
rtk fvm dart run pigeon --input packages/fluttea_security/pigeons/security_api.dart
rtk fvm dart analyze          # harus 0 issue
rtk fvm dart format --set-exit-if-changed lib test
rtk fvm flutter test
rtk fvm flutter run --flavor dev -t lib/main_dev.dart
rtk fvm flutter build apk --release --flavor prod -t lib/main_prod.dart --obfuscate --split-debug-info=build/symbols
```

## Boundaries
- Boleh tanpa tanya: baca file, analyze, test, format, tambah feature mengikuti template.
- Tanya dulu: tambah/hapus package, ubah core/network, ubah core/security, ubah konfigurasi platform (Gradle, Info.plist, Package.swift), ubah flavor.
- Dilarang: commit secret/keystore/`.env`, mematikan pinning di prod, `badCertificateCallback` yang selalu `true`, pinning hanya di `validateCertificate` (post-response), `dynamic` tanpa alasan, `// ignore:` tanpa alasan tertulis.
