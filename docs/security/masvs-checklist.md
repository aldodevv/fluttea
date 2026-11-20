# OWASP MASVS v2.0 Compliance Checklist — Fluttea

Dokumen ini memetakan kepatuhan arsitektur dan implementasi keamanan Flutter App Template (**Fluttea**) terhadap standar **OWASP Mobile Application Security Verification Standard (MASVS v2.0)** dan **MASTG (Mobile Application Security Testing Guide)**.

---

## Ringkasan Kepatuhan

| Kategori MASVS | Deskripsi Fokus | Status Fluttea | Komponen / Implementasi Utama |
|---|---|---|---|
| **MASVS-STORAGE** | Keamanan data lokal & privasi | **PASSED** | `SecureStorage` (Keystore/Keychain), `data_extraction_rules.xml`, `allowBackup="false"`, `AppLog` PII masking |
| **MASVS-CRYPTO** | Kriptografi kuat & manajemen kunci | **PASSED** | AES-256-GCM, ChaCha20-Poly1305, X25519 ECDH + HKDF, Argon2id KDF, CSPRNG nonces |
| **MASVS-AUTH** | Autentikasi & manajemen sesi | **PASSED** | Sesi terisolasi `SessionNotifier`, secure token rotation, clean logout wipe, auto-redirect guard |
| **MASVS-NETWORK** | Keamanan komunikasi jaringan | **PASSED** | Pre-send SPKI & leaf pinning via `SecurityContext`, cleartext dilarang, Hmac anti-replay signature |
| **MASVS-PLATFORM** | Interaksi OS & proteksi layar | **PASSED** | `FLAG_SECURE`, iOS privacy blur, `ClipboardGuard`, intent filtering aman, permission minimal |
| **MASVS-CODE** | Kualitas kode & supply chain | **PASSED** | R8 + `--obfuscate --split-debug-info`, zero warning analyze, Gitleaks, OSV-Scanner 100% clean |
| **MASVS-RESILIENCE** | Anti-tamper, anti-hook, RASP | **PASSED** | `SecurityGate`, multi-level `SecurityPolicy` (allow, warn, restrict, block, wipe), Pigeon native stubs |

---

## 1. MASVS-STORAGE: Penyimpanan Data & Privasi

### Checklist & Verifikasi
- [x] **MASVS-STORAGE-1: Kredensial sensitif disimpan di hardware-backed secure storage.**
  - *Implementasi:* `lib/core/storage/secure/secure_storage.dart` menggunakan `FlutterSecureStorage` dengan opsi `KeychainAccessibility.first_unlock_this_device` pada iOS dan `EncryptedSharedPreferences` / Android Keystore namespace `fluttea_secure_vault` pada Android.
  - *Verifikasi:* Unit test `test/core/storage/secure_storage_test.dart` dan `test/features/auth/auth_flow_test.dart`.
- [x] **MASVS-STORAGE-2: Data aplikasi dikecualikan dari cadangan otomatis (cloud & adb backup).**
  - *Implementasi:* `android/app/src/main/AndroidManifest.xml` menetapkan `android:allowBackup="false"` dan `android:fullBackupContent="false"`. `android/app/src/main/res/xml/data_extraction_rules.xml` mengecualikan seluruh domain `root`, `file`, `database`, dan `sharedpref` dari transfer cloud maupun device-to-device.
- [x] **MASVS-STORAGE-3: Cache in-memory dan disk dibersihkan secara deterministik.**
  - *Implementasi:* `MemoryCache` dilengkapi TTL otomatis. `AuthNotifier.logout()` membersihkan semua token di `SecureStorage`, menghapus session state, dan cache dibuang saat logout.
- [x] **MASVS-STORAGE-4: Log aplikasi tidak membocorkan PII atau data sensitif.**
  - *Implementasi:* `lib/core/logging/pii_masker.dart` secara otomatis mendeteksi dan me-masking email, token JWT, password, nomor kartu kredit, dan NIK sebelum log diteruskan ke Talker sink. Di flavor `prod`, log level dibatasi dan DevTools dinonaktifkan secara compile-time tree-shake.

---

## 2. MASVS-CRYPTO: Kriptografi

### Checklist & Verifikasi
- [x] **MASVS-CRYPTO-1: Menggunakan cipher suite modern dan terakreditasi standar industri.**
  - *Implementasi:* `AesGcmSuite` (AES-256-GCM dengan 96-bit unique nonce dan 128-bit authentication tag) serta `ChaCha20Suite` (ChaCha20-Poly1305 AEAD). Tersedia `CipherRegistry` untuk handshake dinamis.
  - *Format Envelope:* `{v: 1, suite: "aes-256-gcm", kid: "k1", nonce: "...", ct: "...", tag: "..."}` memfasilitasi rotasi algoritma dan kunci tanpa merusak backward-compatibility.
- [x] **MASVS-CRYPTO-2: Pertukaran kunci aman (Key Agreement) tanpa hardcoded keys.**
  - *Implementasi:* `KeyAgreementService` (`lib/core/security/crypto/key_agreement.dart`) menggunakan algoritma kurva eliptik X25519 ECDH dipadukan dengan HKDF-SHA256 untuk menghasilkan symmetric session key secara independen di setiap session.
- [x] **MASVS-CRYPTO-3: Password KDF menggunakan memory-hard hashing.**
  - *Implementasi:* `PasswordKdf` (`lib/core/security/hashing/password_kdf.dart`) menyediakan implementasi utama Argon2id dengan parameter standar OWASP (`memorySize: 65536 KB`, `iterations: 3`, `lanes: 4`) serta fallback PBKDF2-HMAC-SHA256.
- [x] **MASVS-CRYPTO-4: Generator bilangan acak CSPRNG (Cryptographically Secure Pseudo-Random Number Generator).**
  - *Implementasi:* `AppSecureRandom` (`lib/core/security/secure_random.dart`) menggunakan `Random.secure()` OS native untuk IV, salt, secret challenge, dan generator RFC 4122 UUID v4.

---

## 3. MASVS-AUTH: Autentikasi & Manajemen Sesi

### Checklist & Verifikasi
- [x] **MASVS-AUTH-1: Arsitektur sesi terpusat dengan transisi state deterministik.**
  - *Implementasi:* `SessionNotifier` (`lib/core/state/session_state_provider.dart`) mengelola `SessionState` (sealed class: `unauthenticated`, `authenticated`, `expired`).
- [x] **MASVS-AUTH-2: Route protection & redirect guard di level router.**
  - *Implementasi:* `lib/app/router/routes.dart` mengimplementasikan redirect guard GoRouter yang reaktif mendengarkan `sessionProvider`. Akses ke rute terproteksi (`/`, `/settings`) saat belum login otomatis dibelokkan ke `/auth/login`.
- [x] **MASVS-AUTH-3: Mekanisme Logout Bersih (Fail-Safe Wipe).**
  - *Implementasi:* `AuthNotifier.logout()` menghapus token autentikasi di secure storage, memanggil remote revocation endpoint, dan me-reset seluruh state Riverpod ke `unauthenticated`.
- [x] **MASVS-AUTH-4: Signature Request Anti-Replay.**
  - *Implementasi:* `HmacSigner` (`lib/core/security/hashing/hmac_signer.dart`) menghasilkan header `X-Signature`, `X-Timestamp`, `X-Nonce`, dengan verifikasi konstan (`constantTimeCompare`) dan toleransi clock drift maksimal 300 detik.

---

## 4. MASVS-NETWORK: Komunikasi Jaringan

### Checklist & Verifikasi
- [x] **MASVS-NETWORK-1: Seluruh komunikasi menggunakan TLS dan menolak cleartext traffic.**
  - *Implementasi:* `network_security_config.xml` (`cleartextTrafficPermitted="false"`), iOS ATS default tanpa `NSAllowsArbitraryLoads`.
- [x] **MASVS-NETWORK-2: Penegakan Pre-Send SSL/TLS Pinning.**
  - *Implementasi:* Pre-send pinning diverifikasi langsung di level socket TLS handshake (`dart:io` `SecurityContext` + `badCertificateCallback`). Pinning diverifikasi SEBELUM byte HTTP request terkirim ke kabel jaringan.
  - *Live Test Proof:* `test/core/security/pinning_live_test.dart` menguji server live HTTPS lokal: ketika pin salah, handshake langsung diputus dan server menerima tepat **0 bytes data**.
- [x] **MASVS-NETWORK-3: Fallback & Pin Rotation Strategy.**
  - *Implementasi:* Matriks pinning mendukung SPKI (Subject Public Key Info) SHA-256 base64 dengan pin cadangan (backup pin) untuk memastikan rotasi sertifikat di cloud load balancer tidak menyebabkan outage pada aplikasi.

---

## 5. MASVS-PLATFORM: Interaksi Platform & Privasi

### Checklist & Verifikasi
- [x] **MASVS-PLATFORM-1: Proteksi Tangkapan Layar & App Switcher.**
  - *Implementasi:* `ScreenProtector` (`lib/core/security/privacy/screen_protector.dart`) mengaktifkan `FLAG_SECURE` pada Android dan blur overlay pada app switcher iOS untuk mencegah kebocoran data sensitif saat multitasking.
- [x] **MASVS-PLATFORM-2: Perlindungan Papan Klip (Clipboard Guard).**
  - *Implementasi:* `ClipboardGuard` (`lib/core/security/privacy/clipboard_guard.dart`) menyalin data sensitif dengan timer pembersihan otomatis (default 30 detik) dan field input sensitif memakai `obscureText: true` serta `enableSuggestions: false`.
- [x] **MASVS-PLATFORM-3: Validasi File & Upload Guard.**
  - *Implementasi:* `MagicBytesInspector` (`lib/core/security/file_guard/magic_bytes.dart`) memvalidasi header byte sesungguhnya dari berkas (JPEG, PNG, GIF, WebP, PDF, ZIP) terhadap ekstensinya guna menggagalkan MIME-type spoofing.
  - *Archive Guard:* `ArchiveGuard` memeriksa potensi serangan Zip Slip (directory traversal `../`) dan Zip Bomb (rasio kompresi berlebihan > 100x).

---

## 6. MASVS-CODE: Kualitas Kode & Build Hardening

### Checklist & Verifikasi
- [x] **MASVS-CODE-1: Obfuscation dan Symbol Stripping aktif pada Release Build.**
  - *Implementasi:* Build prod diotomasi dengan perintah:
    `flutter build apk --release --flavor prod -t lib/main_prod.dart --obfuscate --split-debug-info=build/symbols`
    Mencegah reverse-engineering mudah atas nama class, function, dan arsitektur internal.
- [x] **MASVS-CODE-2: Pemindaian Secret Hardcoded (Secret Scanning).**
  - *Implementasi:* `gitleaks` diintegrasikan dalam `./tool/security_audit.sh` dan konfigurasi `.gitleaks.toml`. Hasil audit: **0 leak**.
- [x] **MASVS-CODE-3: Audit Kerentanan Dependensi (SCA).**
  - *Implementasi:* `osv-scanner` memindai seluruh 153 transitive & direct package pada `pubspec.lock`. Hasil audit: **0 vulnerability**.
- [x] **MASVS-CODE-4: Kualitas Kode & Analisis Statis.**
  - *Implementasi:* Lint ketat Very Good Analysis (`analysis_options.yaml`). Hasil `rtk fvm dart analyze --fatal-infos`: **0 issue**.

---

## 7. MASVS-RESILIENCE: Ketahanan Aplikasi (RASP)

### Checklist & Verifikasi
- [x] **MASVS-RESILIENCE-1: Deteksi Root / Jailbreak & Hooking.**
  - *Implementasi:* Modul RASP `SecuritySignals` memantau sinyal: `isRootedOrJailbroken`, `isHookingDetected` (Frida/Xposed), `isDebuggerAttached`, `isEmulator`, `isAppTampered`, `isUnofficialStore`.
- [x] **MASVS-RESILIENCE-2: Kebijakan Tindakan Berjenjang (SecurityPolicy).**
  - *Implementasi:* `SecurityGate` mengevaluasi sinyal menjadi `SecurityVerdict`:
    * `Allow`: Sistem aman, operasi berjalan normal.
    * `Warn`: Sinyal ringan (misal dev options), peringatan ditampilkan.
    * `Restrict`: Pembatasan fitur sensitif (misal biometrik dinonaktifkan).
    * `Block`: Pemblokiran UI agar aplikasi tidak dapat digunakan.
    * `Wipe`: Pembersihan total secure storage dan penutupan paksa aplikasi.
- [x] **MASVS-RESILIENCE-3: Integrasi Native Pigeon Type-Safe.**
  - *Implementasi:* `packages/fluttea_security/` menyediakan Pigeon contract generator untuk integrasi kode audit native Kotlin dan Swift secara langsung tanpa overhead runtime reflect.

