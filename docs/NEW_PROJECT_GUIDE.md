# Panduan: Memulai Project Baru dari Template Fluttea

Panduan praktis langkah-demi-langkah bagi pengembang (*developer onboarding*) untuk mengkloning, mengonfigurasi, dan mengembangkan aplikasi mobile baru berbasis template **Fluttea**.

---

## 1. Prasyarat Lingkungan Pengembangan

Pastikan mesin pengembangan Anda telah memenuhi standar baseline berikut:
* **FVM (Flutter Version Management):** Template ini terkunci di Flutter `3.50.0` (Dart `3.14.0`) melalui file [`.fvmrc`](file:///Users/aldodevv/code/project/fluttea/.fvmrc).
* **Android SDK:** Command-line tools, Platform SDK 36 (target SDK wajib), NDK.
* **iOS (macOS):** Xcode 16+, CocoaPods (opsional, template menggunakan Swift Package Manager secara native).
* **Security CLI:**
  ```bash
  brew install gitleaks osv-scanner
  ```
* **Toolchain dev macOS:**
  Jika menggunakan macOS dengan toolchain custom, pastikan mengekspor:
  ```bash
  export TOOLCHAINS=com.apple.dt.toolchain.XcodeDefault
  ```

Jalankan skrip persiapan awal:
```bash
./tool/setup.sh
```

---

## 2. Inisialisasi & Penggantian Identitas Aplikasi

### 2.1. Duplikasi Template
1. Salin seluruh isi repositori Fluttea ke folder project baru Anda.
2. Inisialisasi repositori Git baru:
   ```bash
   rm -rf .git
   git init
   git branch -M main
   ```

### 2.2. Mengganti Nama & Package Name (Application ID)
Secara default, template menggunakan nama `fluttea` dan package name `com.fluttea.fluttea`.

#### A. Android:
1. **`android/app/build.gradle.kts`**:
   * Ubah `namespace = "com.perusahaan.namaapp"`
   * Ubah `applicationId = "com.perusahaan.namaapp"`
2. **`android/app/src/main/res/values/strings.xml`**:
   * Ubah string `app_name` menjadi nama aplikasi Anda.
3. **Struktur Folder Kotlin (`android/app/src/main/kotlin/`)**:
   * Pindahkan file `MainActivity.kt` ke direktori paket baru Anda (misal `com/perusahaan/namaapp/MainActivity.kt`).

#### B. iOS:
1. Buka proyek iOS di Xcode atau edit `ios/Runner.xcodeproj/project.pbxproj`:
   * Ubah `PRODUCT_BUNDLE_IDENTIFIER` menjadi `com.perusahaan.namaapp`.
2. **`ios/Runner/Info.plist`**:
   * Ubah `CFBundleDisplayName` dan `CFBundleName`.

#### C. Dart / Flutter:
1. **`pubspec.yaml`**:
   * Ubah `name: nama_aplikasi` dan `description`.
2. Jalankan pembaruan dependency:
   ```bash
   rtk fvm flutter pub get
   ```

---

## 3. Konfigurasi Flavor & Endpoint Jaringan

Konfigurasi environment berada terpusat di [lib/app/flavor.dart](file:///Users/aldodevv/code/project/fluttea/lib/app/flavor.dart).

### 3.1. Base URL & Feature Flags
Sesuaikan URL backend untuk masing-masing flavor:
```dart
switch (flavor) {
  case AppFlavor.dev:
    return const AppEnv(
      flavor: AppFlavor.dev,
      name: 'Aplikasi Dev',
      baseUrl: 'https://dev-api.perusahaan.com',
      pinningEnabled: false,      // Boleh nonaktif di dev jika perlu inspeksi proxy
      devToolsEnabled: true,       // Mengaktifkan DevTools Hub
      allowUrlOverride: true,      // Memungkinkan tim QA mengganti URL dari UI
    );
  case AppFlavor.prod:
    return const AppEnv(
      flavor: AppFlavor.prod,
      name: 'Aplikasi',
      baseUrl: 'https://api.perusahaan.com',
      pinningEnabled: true,       // WAJIB aktif di prod (fail-closed)
      devToolsEnabled: false,      // Di-tree-shake mati pada release build
      allowUrlOverride: false,     // Dilarang keras override di prod
    );
}
```

### 3.2. Ekstraksi & Pemasangan SPKI SSL Pinning
Untuk mengamankan koneksi di flavor `prod`:
1. Ekstrak pin SPKI SHA-256 base64 dari domain API backend:
   ```bash
   rtk fvm dart run tool/spki_pin.dart api.perusahaan.com
   ```
2. Daftarkan pin utama dan pin cadangan pada `PinSet` di [lib/core/network/network_providers.dart](file:///Users/aldodevv/code/project/fluttea/lib/core/network/network_providers.dart):
   ```dart
   PinRule.spki(
     host: 'api.perusahaan.com',
     pins: {
       'BASE64_SPKI_PRIMARY_PIN_ANDA...',
       'BASE64_SPKI_BACKUP_PIN_ANDA...',
     },
   )
   ```

---

## 4. Menambahkan Fitur Baru

Untuk menjaga struktur **Feature-First** dan batas maksimal 300 baris per file, gunakan generator resmi:

```bash
./tool/new_feature.sh <nama_fitur>
```
*Contoh:*
```bash
./tool/new_feature.sh product
```

Perintah di atas akan secara otomatis men-generate struktur arsitektur:
```
lib/features/product/
├── data/
│   ├── dto/product_dto.dart
│   ├── product_api.dart
│   └── product_repository.dart
├── domain/models/product_model.dart
├── state/product_notifier.dart
└── presentation/
    ├── screens/product_screen.dart
    └── widgets/product_card.dart
```
Serta kerangka tes unit & widget di:
```
test/features/product/
├── product_repository_test.dart
├── product_notifier_test.dart
└── product_screen_test.dart
```

### Langkah Selanjutnya Setelah Menambah Fitur:
1. Daftarkan rute baru di [lib/app/router/routes.dart](file:///Users/aldodevv/code/project/fluttea/lib/app/router/routes.dart):
   ```dart
   static const String product = '/product';
   // Tambahkan GoRoute di createRouter()
   ```
2. Hubungkan repository ke API backend sesungguhnya.
3. Kembangkan antarmuka menggunakan token `context.colors`, `context.text`, dan `Spacing.*`.

---

## 5. Menjaga Standar Kode & Aturan UI

Template ini menerapkan **aturan nol toleransi** terhadap pelanggaran desain:
1. **Dilarang memakai `Colors.xxx` atau `Color(0x...)` mentah** di dalam `lib/features/`.
2. **Dilarang memakai `fontSize:` mentah** di dalam `lib/features/`.
3. **Selalu gunakan token:**
   * Warna: `context.colors.primary`, `context.statusColors.error`
   * Tipografi: `context.text.titleMedium`, `context.text.bodySmall`
   * Jarak: `Spacing.xs`, `Spacing.sm`, `Spacing.md`, `Spacing.lg`

Jalankan linter mandiri:
```bash
./tool/check_ui_rules.sh
```

---

## 6. Audit Keamanan & Quality Gate Sebelum Push

Sebelum melakukan commit atau push kode ke remote branch, **WAJIB** menjalankan audit komprehensif:

```bash
./tool/security_audit.sh
```
Skrip ini akan memvalidasi secara paralel:
1. **Gitleaks:** Memastikan tidak ada token/rahasia/kunci yang bocor di commit atau workspace.
2. **OSV-Scanner:** Memastikan 0 CVE / kerentanan pada seluruh dependensi di `pubspec.lock`.
3. **UI Rules Guard:** Memastikan nol pelanggaran warna dan font mentah di `lib/features/`.
4. **Dart Static Analysis:** Menuntut 0 issue pada `rtk fvm dart analyze --fatal-infos`.
5. **Code Formatting:** Menuntut seluruh file telah diformat konsisten dengan `dart format`.

---

## 7. Build Rilis Produksi

Lakukan kompilasi rilis menggunakan perintah berikut (wajib mengaktifkan obfuscation dan symbol splitting):

### Android APK Produksi:
```bash
rtk fvm flutter build apk --release --flavor prod -t lib/main_prod.dart --obfuscate --split-debug-info=build/symbols
```

### Android App Bundle (Google Play):
```bash
rtk fvm flutter build appbundle --release --flavor prod -t lib/main_prod.dart --obfuscate --split-debug-info=build/symbols
```

### iOS IPA (App Store / TestFlight):
```bash
rtk fvm flutter build ipa --release --flavor prod -t lib/main_prod.dart --obfuscate --split-debug-info=build/symbols
```
Simpan folder `build/symbols` dengan aman di server CI/CD atau internal storage untuk keperluan simbolisasi crash report (*de-obfuscation*) di Firebase Crashlytics.

