# 01 — Research Protocol (Dependency, Platform, Vulnerability)

Kerjakan sebelum menulis `pubspec.yaml`. Hasil dicatat di `docs/research/`.

## A. Tooling wajib
- Context7 MCP: dokumentasi API terbaru tiap package.
- pub.dev API: `https://pub.dev/api/packages/<nama>` (versi, tanggal rilis, `isDiscontinued`), `/score` untuk pub points.
- https://fluttergems.dev/ sebagai **daftar kandidat saja**. Setiap kandidat harus lolos filter B.
- `rtk flutter pub outdated`, `rtk flutter pub deps --style=compact`.
- Scanner vuln: `osv-scanner --lockfile=pubspec.lock`, Snyk (MCP `snyk_sca_scan`), GitHub Advisory DB.

## B. Filter kelayakan package (semua wajib, kecuali dicatat sebagai pengecualian)
1. Tidak `discontinued`, tidak `replaced by`.
2. Rilis stabil terakhir ≤ 12 bulan (SDK/plugin native ≤ 6 bulan). Tanpa `-beta/-dev/-rc` dan tanpa versi `0.0.x`.
3. Publisher terverifikasi atau org besar (`flutter.dev`, `dart.dev`, `fluttercommunity.dev`, `firebase.google.com`, dsb.).
4. Dart SDK constraint cocok dengan Flutter stable terbaru.
5. Plugin native:
   - **iOS: mendukung Swift Package Manager** (ada `ios/<plugin>/Package.swift` atau `darwin/`). Podspec-only = tolak, kecuali tidak ada alternatif (catat ADR).
   - **Android**: pakai `namespace`, AGP/Gradle/Kotlin modern, tidak ada `jcenter`, compileSdk/targetSdk terbaru, `minSdk` sesuai template, dan **16 KB page size** aman untuk library native (`.so`).
6. Issue terbuka tidak menumpuk (cek 10 issue terbaru, ada respon maintainer). Ada commit ≤ 6 bulan.
7. Lisensi permisif (BSD/MIT/Apache). Tidak copyleft.
8. Transitive dependency sedikit: `pub deps` dibandingkan sebelum dan sesudah. Catat penambahan ukuran.
9. Tidak ada advisory terbuka di OSV/Snyk.
10. Tidak ada package lain di daftar yang sudah memenuhi fungsi yang sama (cek overlap).

Urutan preferensi: SDK/stdlib → package `flutter.dev`/`dart.dev` → `fluttercommunity.dev`/`firebase` → pihak ketiga terawat → tulis sendiri (jika < ±100 baris).

## C. Platform terbaru (verifikasi dari sumber resmi, jangan dari ingatan)
- Flutter stable terbaru + Dart SDK: https://docs.flutter.dev/release/archive
- Swift Package Manager: https://docs.flutter.dev/packages-and-plugins/swift-package-manager (aktifkan, pastikan project baru tanpa Podfile bila semua plugin sudah SPM; catat plugin yang masih butuh CocoaPods).
- Android: target/compile SDK terbaru, edge-to-edge, predictive back, 16 KB page size, Gradle/AGP/Kotlin/JDK yang direkomendasikan Flutter.
  https://developer.android.com/google/play/requirements/target-sdk
- iOS: minimum deployment target yang masih masuk akal, Privacy Manifest (`PrivacyInfo.xcprivacy`) untuk SDK yang membutuhkan, ATS aktif.
- Catat hasil di `docs/research/platform-baseline.md` lengkap dengan URL dan tanggal cek.

## D. Kandidat dan keputusan
Sudah diriset: lihat `docs/research/dependency-log.md` (pilihan, opsional, ditolak) dan `docs/research/raw-snapshot.md` (data mentah ±150 paket). Ulangi `scan` saat upgrade; jangan menambah paket di luar daftar tanpa proses A–C.

## E. Audit kode sendiri
- `rtk dart analyze` 0 issue dengan lint ketat.
- Snyk Code (`snyk_code_scan`) pada `lib/`; Snyk SCA pada `pubspec.lock`; `snyk_secret_scan`; `gitleaks`.
- Semgrep dengan rule set Dart/Flutter + OWASP MASVS bila tersedia.
- Review manual terhadap OWASP MASVS (Storage, Crypto, Auth, Network, Platform, Code, Resilience) → hasil di `docs/research/masvs-checklist.md`.

## F. Output yang harus dihasilkan
- `docs/research/dependency-log.md` — tabel: package, versi, alasan, hasil tiap filter B, SPM ✔/✘, Android ✔/✘, ukuran tambahan, tanggal cek, link advisory.
- `docs/research/rejected.md` — package yang ditolak + alasan (supaya tidak diusulkan ulang).
- `docs/research/platform-baseline.md`
- `docs/research/masvs-checklist.md`
- Ulangi riset tiap kuartal atau sebelum upgrade Flutter major.
