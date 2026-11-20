# Firebase — Evaluasi dan Aturan Pakai

## Penilaian
Semua paket Firebase Flutter dirilis 2026-10-24 (21 hari lalu) oleh `firebase.google.com`, 160/160 poin, lolos filter SPM. Rilis terbaru rapi dan serempak, jadi risiko "tidak terawat" rendah. Masalah yang kamu alami di nyx hampir pasti dari kombinasi: 6 paket Firebase sekaligus, beberapa versi beda major, pemanggilan langsung dari banyak tempat, dan init yang tidak terlindungi. Karena itu aturannya bukan "hindari Firebase" tetapi **batasi dan bungkus**.

## Dipakai (default template)
| Layanan | Paket | Alasan | Catatan |
|---|---|---|---|
| Remote Config | `firebase_remote_config` 7.0.1 | Kill switch, versi minimum, maintenance, feature flag, pin dinamis | Default nilai di-compile; fetch gagal = pakai default |
| Cloud Messaging | `firebase_messaging` 17.0.1 + `flutter_local_notifications` 23.0.2 | Push; notifikasi foreground butuh local notification | Izin notifikasi diminta kontekstual, bukan saat start |
| Crashlytics | `firebase_crashlytics` 6.0.1 | Crash report | Tanpa PII; `setCrashlyticsCollectionEnabled` mengikuti consent |
| App Distribution | **tanpa paket runtime** | Upload dari CI lewat Gradle plugin / `firebase` CLI / fastlane | Nol dampak ukuran app |
| Core | `firebase_core` 5.1.0 | Wajib | |

## Opsional (diaktifkan per project)
- `firebase_app_check` 0.5.1: menempelkan token atestasi (Play Integrity / App Attest) ke layanan Firebase. Berguna bila backend memakai Firebase; terpisah dari atestasi ke backend sendiri.
- Analytics, Performance: tidak default (ukuran, privasi, banyak kasus error init pada nyx). Pasang bila ada kebutuhan produk.

## Pola pembungkus (wajib)
```
core/services/firebase/
├─ firebase_bootstrap.dart      # init dengan try/catch + timeout, mengembalikan FirebaseStatus
├─ remote_config_service.dart   # interface: getString/getBool/getInt/getJson, defaults, fetchAndActivate
├─ firebase_remote_config_service.dart   # implementasi
├─ noop_remote_config_service.dart       # dipakai bila init gagal / flavor tanpa Firebase
├─ push_service.dart  push_token_repository.dart
└─ crash_reporter.dart          # interface + implementasi Crashlytics + noop
```
Aturan:
1. Firebase init **tidak boleh menggagalkan startup**: gagal → `FirebaseStatus.unavailable`, app lanjut dengan `Noop*Service`, error dicatat.
2. Tidak ada `FirebaseXxx.instance` di luar `core/services/firebase/`. Fitur hanya memakai interface (mudah diganti, mudah dites).
3. Remote Config memakai `RcKeys` (const), tipe nilai ditentukan di satu tempat, parsing JSON aman dengan fallback.
4. Satu `firebase_options` per flavor (`firebase_options_dev.dart`, `firebase_options_prod.dart`) dihasilkan `flutterfire configure`.
5. Semua versi paket Firebase dinaikkan bersama (satu PR), tidak sebagian.

## Struktur proyek Firebase
1 Firebase project per app. Di dalamnya 2 app Android (`<id>.dev`, `<id>`) dan 2 app iOS. Remote Config memakai **kondisi per app ID** supaya nilai dev (mis. base URL uji) tidak sampai ke prod. Template menyertakan skrip `tool/rc_template.json` sebagai contoh kondisi.

## Config file
`google-services.json` / `GoogleService-Info.plist` berisi API key Firebase yang tidak rahasia, tetapi **wajib dibatasi** (restriction ke package/bundle ID + SHA-256 di Google Cloud console). Boleh di-commit di repo privat; tetap dikecualikan dari repo publik.

## CI App Distribution
Android: Gradle plugin `com.google.firebase.appdistribution` atau `firebase appdistribution:distribute`. iOS: fastlane / CLI. Autentikasi dengan service account atau token CI di secret store. Jangan simpan kredensial di repo.
