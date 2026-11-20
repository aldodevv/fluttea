# 07 — Flavor, Konfigurasi, Kualitas, Tambahan

## Flavor: hanya `dev` dan `prod`
- Satu `main.dart` (`bootstrap`), dua entry tipis: `main_dev.dart`, `main_prod.dart` (set `AppFlavor`, panggil `bootstrap`).
- `app/flavor.dart` adalah **satu-satunya** tempat `switch(flavor)`. Yang berbeda per flavor ada di satu objek `AppEnv`:
  `name`, `baseUrl` (default), `logLevel`, `pinningEnabled`, `devToolsEnabled`, `allowUrlOverride`, `appIdSuffix`, `appName`.
  Kode lain membaca `AppEnv`, bukan flavor.
- Firebase: 1 project, app dev + prod, `firebase_options_dev/prod.dart` dari `flutterfire configure`.
- Native: Android `productFlavors { dev, prod }` (`applicationIdSuffix ".dev"`, label), iOS: 2 scheme + xcconfig (`Dev.xcconfig`, `Prod.xcconfig`) — tanpa tool tambahan bila bisa. Bila `flutter_flavorizr` dipakai, catat di research (pilih hanya jika benar-benar mengurangi kerja; hasil generate harus kecil).
- Ikon/splash: satu sumber, varian dev diberi badge. Tool pembuat ikon/splash hanya `dev_dependencies`.
- Base URL beda lewat DevTools, **bukan** flavor tambahan. Staging/UAT = ganti URL di DevTools.
- Konfigurasi non-rahasia: `--dart-define-from-file=config/dev.json` / `prod.json` (bukan asset, tetap bukan tempat rahasia). Rahasia nyata hanya dari server setelah autentikasi.

## DevTools (`core/devtools/`, hanya non-prod)
Tab terpisah, tiap file < 200 baris: **Env** (flavor, versi, ganti base URL, reset), **Network** (inspector, copy cURL), **Storage** (lihat/hapus key non-sensitif), **Log**, **Security** (hasil gate, simulasi sinyal), **State** (daftar provider + state + reset manual). Dibuka via gesture tersembunyi/shake; prod build meniadakannya (tree-shaken lewat `AppEnv.devToolsEnabled` const).

## Kualitas & CI
- Lint: `flutter_lints` atau `very_good_analysis` (satu), plus: `prefer_const_constructors`, `require_trailing_commas`, `avoid_dynamic_calls`, `unawaited_futures`, `use_build_context_synchronously`, `always_declare_return_types`, `strict-casts/inference/raw-types: true`.
- Test: unit (notifier, handler, mapper, crypto vektor uji), widget (komponen global), golden terbatas, 1–2 integration_test (login → home). Target coverage inti `core/` ≥ 80%.
- CI (GitHub Actions/Jenkins/Bitrise): `pub get` → `analyze` → `format` → `test` → `check_ui_rules` → `osv-scanner`/Snyk/gitleaks → build apk/ipa → ukuran (`--analyze-size`) dibanding batas.
- Anggaran ukuran: catat di `docs/research/size-budget.md`; PR yang menambah > 300 KB wajib alasan.
- Pre-commit: format + analyze + gitleaks.
- Conventional commits, CHANGELOG, versi via `pubspec.yaml` + build number dari CI.
- `.gitignore` ketat: `build/`, `.DS_Store`, `*.jks`, `key.properties`, `.env*`, `local.properties`, `*.log`, (`GoogleService-Info.plist`/`google-services.json`: lihat `research/firebase.md`).

## Tambahan best practice yang ikut template
| Area | Isi |
|---|---|
| Error global | `FlutterError.onError`, `PlatformDispatcher.onError` → `AppLog` (Talker) + `CrashReporter` (Crashlytics, lihat `research/firebase.md`; init Firebase tidak boleh menggagalkan startup) |
| Logging | `AppLog` di atas Talker; redaksi PII; UI log di DevTools |
| Localization | `flutter_localizations` + `intl` + ARB (`gen_l10n` resmi). Key `{kategori}.{konteks}.{elemen}`; paritas id/en dicek skrip |
| Navigasi | go_router, guard auth, deep link validasi, `redirect` berbasis `SessionController` |
| Update paksa & maintenance | Layar terpisah, dipicu `MaintenanceInterceptor`/versi minimum dari server |
| Konektivitas | `ConnectivityService` + banner offline global |
| Aksesibilitas | text scale, kontras, Semantics, target 48dp |
| Performa | `const` luas, `RepaintBoundary` terukur, list lazy, gambar di-cache + resize, hindari rebuild lebar; profiling via DevTools sebelum optimasi |
| Android modern | edge-to-edge, predictive back (`PopScope`), 16 KB, R8 full |
| iOS modern | SPM, Privacy Manifest, Dynamic Island/safe area |
| Dokumentasi | ADR di `docs/adr/NNN-judul.md` untuk tiap keputusan non-standar |
| Skrip | `tool/`: `audit.sh` (osv+snyk+gitleaks), `check_ui_rules.sh`, `l10n_parity.sh`, `size.sh`, `new_feature.sh <nama>` |
| Upgrade | rutinitas bulanan: `pub outdated`, riset ulang dependency kuartalan, upgrade Flutter ke stable terbaru dengan catatan migrasi |
| Template hygiene | repo template punya `example` fitur kecil dan test hijau; tiap perubahan standar memperbarui docs |
