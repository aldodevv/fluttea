# 06 — Security

Acuan: OWASP MASVS + MASTG, Android/iOS security guidance. Prinsip: **client tidak bisa dipercaya sepenuhnya**; kontrol client menaikkan biaya serangan, keputusan akhir ada di server.

```
core/security/
├─ crypto/
│  ├─ cipher_suite.dart        # interface: id, encrypt, decrypt
│  ├─ aes_gcm_suite.dart  chacha20_suite.dart
│  ├─ key_agreement.dart       # X25519 ECDH + HKDF → session key
│  ├─ rsa_oaep_suite.dart      # hanya bila backend mewajibkan (cek paket RSA terawat)
│  ├─ cipher_registry.dart     # pilih suite dinamis dari id (header/config)
│  ├─ envelope.dart            # format: {v, suite, kid, nonce, ct, tag}; versi untuk rotasi
│  └─ key_store.dart           # kunci disimpan di Keychain/Keystore (secure storage), non-extractable bila memungkinkan
├─ hashing/
│  ├─ hash_suite.dart  sha2.dart  sha3.dart  blake2.dart
│  ├─ hmac_signer.dart         # signature request
│  ├─ password_kdf.dart        # Argon2id (utama), PBKDF2-HMAC-SHA256 (fallback), parameter dari const
│  └─ hash_registry.dart       # algoritma dinamis
├─ pinning/                    # lihat research/pinning.md: strategi, pre-send, tes wajib
├─ rasp/
│  ├─ security_provider.dart   # interface; NativeSecurityProvider (default), FreeRaspProvider (opsional)
│  ├─ security_gate.dart       # kumpulkan sinyal → SecurityVerdict(level, reasons)
│  ├─ freerasp_provider.dart   # opsional (Talsec freeRASP)
│  ├─ signals/                 # root_jailbreak, hooking, debugger, emulator, tamper, unofficial_store,
│  │                           # screen_capture, vpn, proxy, time_tamper, dev_options, malware_apps
│  └─ policy.dart              # sinyal → aksi: allow | warn | restrict | block | wipe
├─ attestation/
│  ├─ play_integrity.dart      # Android (token → verifikasi di server)
│  └─ app_attest.dart          # iOS App Attest/DeviceCheck (token → server)
├─ file_guard/
│  ├─ file_policy.dart         # allowlist ekstensi+MIME, ukuran maks
│  ├─ magic_bytes.dart         # cek signature header file vs ekstensi
│  ├─ archive_guard.dart       # batas ukuran ekspansi zip, path traversal
│  ├─ image_sanitizer.dart     # re-encode, buang EXIF/GPS
│  ├─ file_hasher.dart         # SHA-256 → cek ke server/AV
│  └─ scan_client.dart         # interface ke AV server-side (ClamAV / VirusTotal API / vendor)
├─ privacy/
│  ├─ screen_protector.dart    # FLAG_SECURE, blur di app switcher iOS, deteksi screen recording
│  └─ clipboard_guard.dart
└─ secure_random.dart          # Random.secure(), UUID v4/v7
```

## 1. Dio security siap pakai
- **Enkripsi dinamis:** `CipherRegistry` memilih suite dari konfigurasi/handshake. Format `envelope` membawa `v/suite/kid` agar rotasi kunci dan migrasi algoritma tidak memutus klien lama. Tidak ada IV/nonce statis; nonce acak per pesan (AES-GCM 96-bit). Kunci sesi dari ECDH, bukan kunci hardcode.
- **Hashing dinamis:** `HashRegistry` untuk integritas (SHA-256/512, SHA-3, BLAKE2), `HmacSigner` untuk tanda tangan request (timestamp + nonce + body hash untuk anti-replay). Password/PIN → Argon2id (bukan SHA polos).
- **Pinning semua tipe:** semua strategi dan penegakannya (pre-send via `SecurityContext` + `badCertificateCallback`, bukan hanya `validateCertificate` yang berjalan setelah response) ada di `docs/research/pinning.md`. Plugin pinning pihak ketiga tidak dipakai.

### Matriks memilih pinning
| Kondisi backend | Pilihan |
|---|---|
| CA publik, leaf dirotasi sering (Let's Encrypt, cloud LB) | **SPKI pin intermediate + SPKI cadangan** |
| Kunci leaf stabil, kontrol penuh | SPKI pin leaf + 1 cadangan |
| CA internal/private | `private_ca_trust` + SPKI pin |
| Butuh identitas klien | `mtls` + pin |
| Memakai adapter native (`cupertino_http`/`cronet_http`) | `NativeStackPin` (NSPinnedDomains / Cronet). **Tidak berlaku untuk `dart:io`** |
| Pin perlu diubah tanpa rilis | `dynamic_pins` (payload ditandatangani, pin awal tetap compile-time) |
| Dev/staging | Pin boleh dimatikan hanya `kDebugMode` + flavor dev, dengan banner jelas di DevTools |
Aturan: selalu ≥ 2 pin, simpan tanggal kedaluwarsa, uji skrip rotasi, **fail closed** di prod. Pin SPKI adalah data publik: boleh ada di kode, tidak di `.env` asset.

## 2. Checker (native, lihat `research/native-security.md`)
Modul native sendiri `packages/fluttea_security` (Kotlin + Swift, Pigeon) adalah default; freeRASP hanya opsional.
| Area | Sarana | Catatan |
|---|---|---|
| Root/Jailbreak, hooking (Frida/Xposed), debugger, emulator, tamper/integrity, unofficial store | **Modul native** (RootBeer, IOSSecuritySuite, cek sendiri); `freerasp` opsional | Hasil dikirim ke server sebagai sinyal |
| Malware/suspicious apps (Android) | freeRASP malware callback + `QUERY_ALL_PACKAGES` dihindari (kebijakan Play) | Gunakan daftar paket yang di-whitelist per Play policy |
| Device rusak/tidak aman | cek screen lock, developer options, ADB enabled, secure hardware (StrongBox/Secure Enclave) | Lewat platform channel kecil bila package tidak menyediakan |
| Reverse engineering | `--obfuscate --split-debug-info`, R8 full mode + shrink, hapus symbol, jangan bundle `.env`/rahasia, string sensitif dienkripsi | Obfuscation memperlambat, bukan mencegah |
| Integritas build | Play Integrity (Android), App Attest (iOS), verifikasi di server | Wajib server-side |
| File/malware upload | `file_guard/*` + AV server-side; unduhan: cek hash, simpan di folder privat app, buka dengan intent aman | Tidak ada AV engine tanpa server yang layak di mobile |
| Waktu/tamper jam | `time_sync_interceptor` + `Stopwatch` monotonic | Bandingkan header `Date` server |
| Proxy/VPN/MITM | deteksi proxy, VPN sebagai sinyal, pinning | Policy: warn/restrict, bukan sekadar blok |
| Screen capture/recording | FLAG_SECURE, overlay iOS, deteksi `UIScreen.isCaptured` | Via `privacy/` |
| Overlay/tapjacking | `filterTouchesWhenObscured` pada layar sensitif | Android |
| Clipboard | `clipboard_guard` untuk field sensitif; `obscureText` + `enableSuggestions:false` | |
| Deep link/intents | validasi scheme/host, tidak percaya parameter, App Links/Universal Links | |
| WebView | non-aktifkan JS bila tak perlu, allowlist domain, tanpa file access | |

`SecurityGate` dijalankan di `bootstrap` (sebelum UI) dan secara periodik; `policy.dart` dikonfigurasi per project (default: debug = log, prod = restrict/block sesuai sinyal).

## 3. Storage
- Token/kunci: `flutter_secure_storage` (Keychain `first_unlock_this_device`, Android Keystore, `resetOnError` hati-hati). Tidak ada rahasia di `SharedPreferences`.
- Backup: `android:allowBackup="false"`, `dataExtractionRules` kosong, iOS tandai file sensitif `isExcludedFromBackup`.
- Cache disk sensitif terenkripsi (AES-GCM, kunci dari KeyStore). Hapus saat logout.
- Log: tidak menulis PII/token; prod log level `off`/`error`.

## 4. Platform hardening
- Android: `usesCleartextTraffic=false`, `network_security_config` (tanpa user CA di prod), `exported` eksplisit, `FLAG_SECURE` layar sensitif, `minSdk` modern, izin minimal.
- iOS: ATS aktif tanpa pengecualian, Keychain accessibility terbatas, `PrivacyInfo.xcprivacy`, tidak ada `NSAllowsArbitraryLoads`.
- Tidak ada keystore, `key.properties`, `google-services` rahasia di git; CI memakai secret store.

## 5. Supply chain & vulnerability
- `pubspec.lock` di-commit (aplikasi). Versi diikat caret terkontrol, upgrade lewat PR terjadwal.
- CI: `osv-scanner`, Snyk SCA/Code/Secret, `gitleaks`, `dart pub outdated`; fail pada severity High/Critical tanpa exception tertulis.
- Tidak ada git/path dependency, fork, atau `dependency_overrides` tanpa ADR + tanggal hapus.
- Lihat `docs/research/dependency-log.md` untuk status advisory tiap paket.

## 6. Tambahan yang disarankan
- Session: refresh token rotasi + reuse detection, idle timeout (memakai `ResetOn.backgroundFor`), logout bersih (hapus secure storage, cache, state session).
- Biometrik: `local_auth` untuk membuka kunci lokal (CryptoObject-bound bila ada), bukan sekadar bool.
- Anti-replay: nonce + timestamp pada request sensitif.
- Certificate Transparency/pinning report ke backend.
- Threat model singkat per project (`docs/research/threat-model.md`): aset, aktor, jalur serangan.
- Pentest checklist sebelum rilis (MASTG), termasuk uji MITM dengan proxy + user CA.

## Dilarang
`badCertificateCallback` yang selalu `true` selain `kDebugMode`+dev; hardcode key/IV; `Random()` untuk keperluan keamanan; MD5/SHA-1 untuk keamanan; ECB; menyimpan token di prefs; log token; mengirim PII ke pihak ketiga tanpa persetujuan.
