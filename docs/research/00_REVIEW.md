# 00 — Hasil Riset untuk Review

Tanggal data: 2026-11-14. Sumber: pub.dev API, OSV.dev, GitHub API, docs.flutter.dev, developer.android.com, Context7 (Dio, Riverpod, Talker), source Dio/Dart. Data mentah: `raw-snapshot.md`.
Status: **riset selesai, belum ada kode project.** Setelah kamu setuju atau mengoreksi bagian ini, fase build (`../08_BUILD_PLAN.md`) dimulai.

## 1. Jawaban atas 10 poin keputusan

| # | Keputusan kamu | Hasil riset / keputusan yang diusulkan |
|---|---|---|
| 1 | Dependency boleh asal seamless; codegen secukupnya | **State = `flutter_riverpod` 3.5 tanpa codegen** (satu class + satu baris provider, satu file; bukan 3 file seperti bloc). Codegen hanya `freezed` + `json_serializable` untuk model/DTO. Tanpa `riverpod_generator`, `auto_route`, `injectable`, `flutter_gen`. Detail: `../05_STATE.md` |
| 2 | Dio adaptif karena backend belum disetujui | `NetworkProfile` (preset) + `ResponseSchema` (envelope bisa dikonfigurasi, HTTP-native, problem+json, JSON:API, GraphQL, custom). Semua bisa diganti tanpa menyentuh feature. Detail: `../04_NETWORK.md` bagian "Adaptif" |
| 3 | Pinning semua tipe sampai level HTTP | **Koreksi penting:** `validateCertificate` Dio berjalan setelah response diterima (terbukti di source `io_adapter.dart`), jadi request sudah terkirim. Desain baru: pin dicek **sebelum request dikirim** lewat `SecurityContext(withTrustedRoots:false)` + `badCertificateCallback`. Detail: `pinning.md` |
| 4 | Package lain compact, adaptif, aman | Daftar final 24 runtime + 8 dev (`dependency-log.md`). Tiap paket lolos filter; yang gagal ada di tabel tolak |
| 5 | Riset semua package | Selesai untuk ±150 paket (`raw-snapshot.md`), ringkasan di `dependency-log.md` |
| 6 | Security checker via native bila Flutter tidak cukup | Diterima. Modul native sendiri (`packages/fluttea_security`, Kotlin + Swift, Pigeon) dengan antarmuka `SecurityProvider`. freeRASP jadi provider opsional. Detail: `native-security.md` |
| 7 | Firebase? | **Ya, dipakai, tetapi dibungkus** dan tidak boleh membuat app crash bila gagal init. 1 Firebase project per app, berisi app dev + prod. Pakai: Remote Config, Messaging, Crashlytics, App Distribution (CLI, tanpa SDK runtime), App Check opsional. Tidak default: Analytics, Performance. Detail: `firebase.md` |
| 8 | Format respons belum tahu | Disiapkan `ResponseSchema` preset + custom (lihat #2) |
| 9 | Dijadikan opsi agar mobile menyesuaikan backend | `NetworkProfile` mengatur: skema respons, auth scheme, enkripsi on/off + suite, signature, pinning, pagination style, retry. Satu file konfigurasi per project |
| 10 | Android/iOS saja | Web/desktop dihapus dari template (`flutter create --platforms=android,ios`) |

## 2. Temuan yang mengubah rencana awal
1. **Pinning pasca-response itu tidak cukup.** Pola resmi di README Dio mengecek fingerprint setelah request terkirim. Docs saya sebelumnya (`06`) juga mengandalkannya. Sudah diperbaiki.
2. **`native_pinning` lewat `network_security_config`/`NSPinnedDomains` tidak berlaku untuk `dart:io`.** Dart memakai BoringSSL sendiri, bukan stack jaringan OS. Saya menandai ini **perlu dibuktikan lewat tes di emulator** (fase 6), tetapi desain tidak bergantung padanya. Native pinning hanya relevan bila memakai adapter native (`cupertino_http`/`cronet_http`).
3. **Flutter stable sekarang 3.50.0 (Dart 3.14.0, 2026-11-11).** Mesin ini memakai 3.47.9 (Dart 3.13.7). `riverpod 3.5` butuh Dart ≥ 3.12 dan `freezed 4` butuh ≥ 3.13, jadi 3.47.9 masih cukup, tetapi template sebaiknya dibangun di 3.50.0.
4. **SPM sudah default sejak Flutter 3.44**; CocoaPods hanya fallback untuk plugin yang belum SPM. Semua paket pilihan bertag `is:swiftpm-plugin` (atau implementasi federated-nya).
5. **Target API 36 wajib** untuk app baru/update di Play sejak 2026-08-31 (perpanjangan sampai 2026-11-01 sudah lewat). SDK 36 dan 36.1 sudah terpasang di mesin ini.
6. **freeRASP 9.0.0 baru rilis kemarin** (major, banyak breaking). Free tier juga mengirim telemetri ke Talsec (harus diverifikasi kebijakannya sebelum dipakai di app sensitif). Karena itu bukan default.
7. **Logger:** `pretty_dio_logger` (845 hari) dan `dio_smart_retry` (752 hari) tidak aktif. `talker` aktif (20 hari) dan jadi inti log + UI log, tetapi **redaksi field sensitif tidak ada bawaan** pada `talker_dio_logger` (hanya filter request/response), jadi interceptor log ditulis sendiri dan mengirim ke Talker.
8. **Tidak perlu flavorizr/launcher_icons/native_splash di runtime template.** Setup flavor, ikon, splash dikerjakan satu kali saat membuat template. `flutter_launcher_icons` juga sudah 521 hari tanpa rilis.
9. **Alat scan lokal belum terpasang:** `osv-scanner`, `gitleaks`, `semgrep`, `snyk` CLI. Snyk tersedia lewat MCP. Perlu persetujuan kamu untuk `brew install osv-scanner gitleaks`.

## 3. Stack final yang diusulkan (ringkas)
Runtime: `flutter_riverpod`, `go_router`, `dio`, `talker` + `talker_flutter`, `cryptography` + `cryptography_flutter`, `crypto`, `asn1lib`, `flutter_secure_storage`, `shared_preferences`, `local_auth`, `package_info_plus`, `device_info_plus`, `connectivity_plus`, `firebase_core`, `firebase_remote_config`, `firebase_messaging`, `firebase_crashlytics`, `flutter_local_notifications`, `freezed_annotation`, `json_annotation`, `intl` + `flutter_localizations`.
Dev: `build_runner`, `freezed`, `json_serializable`, `pigeon`, `very_good_analysis`, `mocktail`, `integration_test`.
Opsional per project: `firebase_app_check`, `freerasp` (8.3.0 dulu, 9.x setelah patch pertama), `dio_http2_adapter`, `cupertino_http`/`cronet_http`, `cached_network_image`, `flutter_svg`, `url_launcher`, `permission_handler`, `image_picker`/`file_picker`, `share_plus`, `app_links`, `skeletonizer`, `lottie`.
Alasan per paket, versi, dan hasil filter: `dependency-log.md`.

## 4. Risiko yang masih terbuka
- Riverpod: kurva belajar (konsep `ref`, `autoDispose`). Mitigasi: contoh siap pakai di template + aturan lint. Alternatif bila kamu tidak mau: state buatan sendiri di SDK seperti di draft `05` lama (±300 baris dipelihara sendiri).
- Pinning leaf SPKI memakai `withTrustedRoots:false`: **tidak ada validasi rantai CA**. Kompensasinya: pin per-host, cek tanggal berlaku, minimal 2 pin, plus lapisan CA-pin. Wajib uji dengan server HTTPS lokal.
- Heuristik root/jailbreak native bisa di-bypass; ini menaikkan biaya serangan, bukan menutup. Keputusan akhir tetap server (Play Integrity / App Attest).
- `IOSSecuritySuite` berlisensi `NOASSERTION` di GitHub API: baca file LICENSE sebelum dipakai.
- Satu Firebase project berisi app dev dan prod: Remote Config perlu kondisi per app ID agar nilai dev tidak bocor ke prod.

## 5. Keputusan yang saya butuhkan dari kamu
1. Setuju Riverpod (tanpa codegen) atau pilih state buatan sendiri?
2. Setuju modul security native sendiri sebagai default, freeRASP opsional?
3. Boleh upgrade Flutter lokal ke 3.50.0 (`flutter upgrade`)?
4. Boleh `brew install osv-scanner gitleaks`?
5. minSdk Android dan iOS minimum (usulan: Android 26, iOS 15; default Flutter bila tidak ada preferensi).
6. Nama app, bundle id/package, organisasi untuk `flutter create`.
7. Firebase: sudah ada project, atau kita siapkan placeholder dan `flutterfire configure` dikerjakan kamu?

## 6. Status keputusan dan fase 1 (update)
Jawaban user: Riverpod disetujui bila memenuhi kriteria (lihat `05_STATE.md`; kriteria diuji di fase 4), modul native default, Flutter diganti via FVM, `osv-scanner` + `gitleaks` terpasang (formula resmi homebrew-core: Apache-2.0/MIT, bottled, upstream Google dan gitleaks), minSdk dinaikkan ke 29 dan iOS 16, nama sementara **fluttea** (`com.fluttea.fluttea`, mudah diganti sebelum rilis pertama), Firebase disiapkan placeholder dulu.
Fase 1 selesai dan terverifikasi: lihat bagian "Hasil fase 1" di `platform-baseline.md`. Perubahan dari rencana: `cryptography_flutter` dikeluarkan (KGP), dan `material_ui`/`cupertino_ui` menggantikan `flutter/material.dart`.
