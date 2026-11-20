# 🍵 Fluttea

> **Template Aplikasi Flutter yang Compact, Aman, Adaptif, dan Teruji.**
> Dirancang sebagai fondasi awal standar enterprise untuk semua proyek mobile Android & iOS.

[![Flutter](https://img.shields.io/badge/Flutter-3.50.0-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.14.0-0175C2?logo=dart)](https://dart.dev)
[![OWASP MASVS](https://img.shields.io/badge/OWASP%20MASVS-v2.0%20Compliant-green)](docs/security/masvs-checklist.md)
[![Tests](https://img.shields.io/badge/Tests-272%20Passed-brightgreen)](test/)
[![Security Audit](https://img.shields.io/badge/Security%20Audit-0%20Vulnerabilities-success)](tool/security_audit.sh)
[![License](https://img.shields.io/badge/License-Proprietary-blue)]()

---

## 🌟 Mengapa Fluttea?

Fluttea dibangun dari pelajaran nyata (*lessons learned*) proyek-proyek terdahulu untuk mengeliminasi kelemahan umum pada aplikasi mobile berskala besar:
* **Bebas Bloat & Codegen Lambat:** Menggunakan `flutter_riverpod` 3.5 tanpa generator (`build_runner` hanya untuk model data serializable dan Pigeon).
* **Keamanan Keras (Defense-in-Depth):** Mematuhi standar **OWASP MASVS v2.0**; SSL Pinning dilakukan *pre-send* pada layer socket TLS (bukan post-response yang membocorkan data request), enkripsi envelope dinamis (AES-GCM & ChaCha20), deteksi integritas RASP native, proteksi tangkapan layar, pembersih clipboard, dan penangkal Zip Slip / Zip Bomb.
* **Network Modular ("Dio Lego"):** Abstraksi jaringan yang siap beradaptasi dengan segala format respon backend (Envelope standar, plain JSON, problem+json) tanpa mengubah satu pun baris kode di layer fitur.
* **Disiplin Design System Mutlak:** Linter otomatis (`tool/check_ui_rules.sh`) memblokir penggunaan warna, font, dan jarak mentah di dalam fitur. Seluruh UI otomatis mendukung Dark Mode secara sempurna.
* **DevTools Hub Bawaan:** Panel diagnostik interaktif (Environment switcher, Network cURL inspector, Storage browser, Log filter, RASP simulator, dan Component Gallery) yang otomatis di-*tree-shake* mati total di flavor `prod`.

---

## 🏗️ Arsitektur Proyek (Feature-First)

Struktur direktori disusun modular dengan batas tanggung jawab yang tegas:

```
fluttea/
├── lib/
│   ├── main_dev.dart            # Titik masuk flavor Development
│   ├── main_prod.dart           # Titik masuk flavor Production
│   ├── app/                     # Setup aplikasi, GoRouter, dan DI global
│   ├── core/                    # Modul inti & fondasi aplikasi
│   │   ├── constants/           # HANYA konstanta (UI tokens, network, storage)
│   │   ├── devtools/            # Panel diagnostik DevTools Hub (6 tab terpisah)
│   │   ├── errors/              # Result<T> sealed class & Failure mapper
│   │   ├── logging/             # AppLog + Talker sink dengan auto PII masking
│   │   ├── network/             # Dio lego wrapper, 7 interceptors, SSL pinning
│   │   ├── security/            # Crypto envelope, hashing, RASP, file guard, privacy
│   │   ├── state/               # State lifecycle & helper Riverpod
│   │   ├── storage/             # SecureStorage, PreferencesStorage, MemoryCache
│   │   ├── theme/               # Design tokens, Material 3, ThemeExtensions
│   │   └── widgets/             # Global widget library (buttons, inputs, layout, feedback)
│   └── features/                # Modul bisnis mandiri
│       ├── _template/           # Template fitur bersih (acuan scaffolding)
│       ├── splash/              # Splash screen & router session redirect
│       ├── auth/                # Login form, secure credential storage, DTO & repo
│       ├── settings/            # Pengaturan tema, bahasa, biometrik, logout
│       └── home/                # Showcase navigasi modul
├── packages/
│   └── fluttea_security/        # Modul native security RASP (Pigeon Kotlin & Swift)
├── test/                        # 272 automated unit & widget tests
├── integration_test/            # End-to-end device integration tests
├── docs/                        # Panduan lengkap, research, STRIDE threat model, MASVS checklist, ADR
└── tool/                        # Skrip operasional CLI & audit keamanan
```

---

## 🚀 Memulai (Quick Start)

### 1. Prasyarat Sistem
* Flutter terkunci di versi `3.50.0` (Dart `3.14.0`) via [`.fvmrc`](file:///.fvmrc).
* Pasang FVM dan alat audit keamanan:
  ```bash
  brew install gitleaks osv-scanner
  dart pub global activate fvm
  ```

### 2. Setup Awal
Jalankan skrip persiapan project:
```bash
./tool/setup.sh
```

### 3. Menjalankan Aplikasi
* **Mode Development (dengan DevTools Hub aktif):**
  ```bash
  rtk fvm flutter run --flavor dev -t lib/main_dev.dart
  ```
* **Mode Production:**
  ```bash
  rtk fvm flutter run --flavor prod -t lib/main_prod.dart
  ```

---

## 🛠️ CLI Tools & Perintah Operasional

Seluruh perintah di Fluttea diproxy melalui `rtk` (*Rust Token Killer*) untuk efisiensi eksekusi:

```bash
# Analisis Kode (Wajib 0 Issue)
export TOOLCHAINS=com.apple.dt.toolchain.XcodeDefault
rtk fvm dart analyze --fatal-infos

# Format Kode Konsisten
rtk fvm dart format --output=none --set-exit-if-changed lib test tool integration_test

# Menjalankan Seluruh Automated Tests (272 Tests)
rtk fvm flutter test

# Menjalankan Audit Keamanan Lengkap (Gitleaks + OSV-Scanner + UI Rules + Analyze + Format)
./tool/security_audit.sh

# Uji Resistensi MITM Proxy & Live SSL Pinning
./tool/test_mitm.sh

# Scaffolding Fitur Baru
./tool/new_feature.sh <nama_fitur>

# Ekstraksi SPKI Hash untuk Pinning Domain Baru
rtk fvm dart run tool/spki_pin.dart <nama_domain.com>
```

---

## 📦 Kompilasi Rilis Produksi (Build Release)

Build produksi wajib mengaktifkan **obfuscation** dan **symbol splitting**:

```bash
# Android APK:
rtk fvm flutter build apk --release --flavor prod -t lib/main_prod.dart --obfuscate --split-debug-info=build/symbols

# Android App Bundle (Play Store):
rtk fvm flutter build appbundle --release --flavor prod -t lib/main_prod.dart --obfuscate --split-debug-info=build/symbols

# iOS IPA (App Store / TestFlight):
rtk fvm flutter build ipa --release --flavor prod -t lib/main_prod.dart --obfuscate --split-debug-info=build/symbols
```

---

## 📚 Dokumentasi & Panduan Lengkap

* **[Panduan Memulai Project Baru dari Template](docs/NEW_PROJECT_GUIDE.md)**
* **[OWASP MASVS v2.0 Checklist](docs/security/masvs-checklist.md)**
* **[STRIDE Threat Model](docs/security/threat-model.md)**
* **[Pelajaran dari Nyx (Lessons Learned)](docs/00_LESSONS_FROM_NYX.md)**
* **[Protokol Riset & Pemilihan Dependency](docs/01_RESEARCH_PROTOCOL.md)**
* **[Struktur Folder & Penamaan](docs/02_STRUCTURE.md)**
* **[Aturan UI, Tokens & Theme](docs/03_CONST_UTILS_UI.md)**
* **[Arsitektur Jaringan (Dio Lego)](docs/04_NETWORK.md)**
* **[State Management & Riverpod Guidelines](docs/05_STATE.md)**
* **[Panduan Keamanan & Kriptografi](docs/06_SECURITY.md)**
* **[Flavor & Quality Assurance](docs/07_FLAVOR_QUALITY.md)**
* **[Build Plan & Definition of Done](docs/08_BUILD_PLAN.md)**

### Architecture Decision Records (ADR)
* [ADR 0001: Riverpod 3.5 Tanpa Codegen](docs/adr/0001-riverpod-without-codegen.md)
* [ADR 0002: Pre-Send TLS SPKI Pinning vs Post-Response Validation](docs/adr/0002-pre-send-pinning-vs-post-response.md)
* [ADR 0003: Arsitektur Modular Dio Lego Network Wrapper](docs/adr/0003-dio-lego-network-wrapper.md)
* [ADR 0004: Penegakan Token Palette & Larangan Nilai Mentah pada UI](docs/adr/0004-token-and-theme-discipline.md)
* [ADR 0005: Integrasi Native Security (RASP) Melalui Pigeon Type-Safe IPC](docs/adr/0005-native-security-rasp-via-pigeon.md)

---

## 📄 Lisensi & Hak Cipta
Dikelola sebagai template arsitektur internal berstandar tinggi.
Dilindungi oleh hak cipta tim pengembang Fluttea.
