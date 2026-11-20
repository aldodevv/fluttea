# STRIDE Threat Model — Fluttea (Flutter App Template)

Dokumen ini membedah ancaman keamanan aplikasi mobile, batas kepercayaan (*trust boundaries*), vektor serangan potensial, mitigasi teknis yang telah diterapkan di **Fluttea**, dan sisa risiko (*residual risk*) yang harus dimitigasi di level backend.

---

## 1. Diagram Batas Kepercayaan (Trust Boundaries)

```
[ User Input / Display ]
         │ (Tangkapan Layar, Keylogger, Tapjacking)
         ▼
┌─────────────────────────────────────────────────────────────┐
│ 📱 FLUTTEA APPLICATION BOUNDARY                             │
│                                                             │
│  [ UI / Presentation Layer ] ── (Obfuscated Dart Code)      │
│         │                                                   │
│  [ Core Security Layer ]                                    │
│    ├── ScreenProtector (FLAG_SECURE, Blur Overlay)          │
│    ├── ClipboardGuard (Auto-Clear Delay)                    │
│    ├── MagicBytes & ArchiveGuard (Zip Slip / Zip Bomb)      │
│    ├── HmacSigner (Anti-Replay Signature)                   │
│    └── SecurityGate & RASP (Root, Hook, Debugger Signals)   │
│         │                                                   │
│  [ Storage Layer ]                                          │
│    ├── SecureStorage ──► [ OS Keystore / Keychain ]         │
│    └── PrefsStorage  ──► [ App Private Sandbox (No Backup)] │
│         │                                                   │
│  [ Network Layer: Dio Lego ]                                │
│    ├── Pre-Send SPKI Pinning                                │
│    ├── Dynamic Cipher Envelope                              │
│    └── PII-Masked Logging                                   │
└─────────────────────────────────────────────────────────────┘
         │
         │  TLS 1.3 Handshake (Pre-Send Pinning Enforced)
         ▼
═══════════════════════════════════════════════════════════════
 [ UNTRUSTED NETWORK BOUNDARY: Public Wi-Fi / Proxy / ISP ]
═══════════════════════════════════════════════════════════════
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│ ☁️ BACKEND BOUNDARY                                         │
│   ├── Reverse Proxy / Cloudflare Edge                       │
│   ├── Token Issuer / OAuth2 / Revocation Store              │
│   └── Attestation Verifier (Play Integrity / App Attest)    │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Analisis Ancaman STRIDE

### 2.1. Spoofing (Pemalsuan Identitas)
| ID | Skenario Ancaman | Vektor Serangan | Mitigasi di Fluttea | Residual Risk / Rekomendasi Backend |
|---|---|---|---|---|
| **S-01** | Penyerang menyamar sebagai server sah (Server Spoofing). | Penyerang memasang root CA palsu di perangkat untuk melakukan inspeksi MITM. | **Pre-send SPKI Pinning** pada level socket TLS handshake via `SecurityContext`. Sertifikat user ditolak di release build (`network_security_config.xml`). | Server harus menerapkan rotasi sertifikat terencana dan mTLS jika memerlukan autentikasi perangkat keras. |
| **S-02** | Penyerang memalsukan identitas request (Request Forgery). | Mengirimkan payload modifikasi yang mengatasnamakan user sah. | `HmacSigner` (`lib/core/security/hashing/hmac_signer.dart`) menandatangani setiap request dengan timestamp, nonce acak, dan body hash. | Backend wajib memverifikasi HMAC signature dan memastikan timestamp berada dalam window toleransi (< 300 detik). |

### 2.2. Tampering (Perusakan & Modifikasi Data)
| ID | Skenario Ancaman | Vektor Serangan | Mitigasi di Fluttea | Residual Risk / Rekomendasi Backend |
|---|---|---|---|---|
| **T-01** | Modifikasi binary APK/IPA (Repackaging). | Membongkar APK, menyuntikkan kode berbahaya, dan merilis ulang di pihak ketiga. | RASP signal `isAppTampered` + `isUnofficialStore` pada `SecurityGate`. | Backend wajib mewajibkan verifikasi token **Google Play Integrity API** dan **Apple App Attest**. |
| **T-02** | Manipulasi memori dan runtime (Hooking). | Menggunakan Frida atau Xposed untuk membypass logic autentikasi atau pinning. | RASP signal `isHookingDetected` dan `isDebuggerAttached`. Native Pigeon provider memantau proses runtime. | Client controls dapat dipintas oleh reverse-engineer berdedikasi tinggi; server-side validation adalah penentu akhir. |
| **T-03** | Path Traversal via berkas archive (Zip Slip). | Mengunggah zip yang berisi entri `../../filename` untuk menimpa file eksekutif lokal. | `ArchiveGuard` (`lib/core/security/file_guard/archive_guard.dart`) memeriksa canonical path sebelum ekstraksi berkas. | Validasi ekstensi dan scan malware server-side tetap wajib dilakukan di storage cloud. |

### 2.3. Repudiation (Penyangkalan Tindakan)
| ID | Skenario Ancaman | Vektor Serangan | Mitigasi di Fluttea | Residual Risk / Rekomendasi Backend |
|---|---|---|---|---|
| **R-01** | User menyangkal telah melakukan transaksi tertentu. | Mengklaim bahwa request dikirimkan oleh pihak ketiga atau terjadi replay. | Request ID unik (`RequestIdInterceptor`), nonce CSPRNG, dan signature HMAC pada setiap transaksi finansial/kritis. | Backend harus menyimpan audit trail immutable dengan signature client dan server timestamp. |

### 2.4. Information Disclosure (Kebocoran Informasi)
| ID | Skenario Ancaman | Vektor Serangan | Mitigasi di Fluttea | Residual Risk / Rekomendasi Backend |
|---|---|---|---|---|
| **I-01** | Kebocoran token dari cadangan perangkat (Backup Extraction). | Menggunakan `adb backup` atau cloud backup untuk mencuri file aplikasi. | `android:allowBackup="false"` dan `data_extraction_rules.xml` mengecualikan seluruh domain database/sharedpref. Token disimpan di Android Keystore / iOS Keychain (`SecureStorage`). | Tidak ada data sensitif yang boleh disimpan di plaintext SharedPreferences. |
| **I-02** | Pengintaian layar (Screen Sniffing / Shoulder Surfing). | Aplikasi jahat merekam layar atau menampilkan preview di app switcher saat berpindah aplikasi. | `ScreenProtector` (`lib/core/security/privacy/screen_protector.dart`) menerapkan `FLAG_SECURE` di Android dan blur privacy overlay di iOS. | Pengguna tetap harus diedukasi untuk tidak membuka layar sensitif di ruang publik. |
| **I-03** | Kebocoran kredensial di log produksi. | Token JWT, password, atau PII tercetak ke Logcat / Console. | `PiiMasker` (`lib/core/logging/pii_masker.dart`) me-masking email, token, NIK, dan nomor kartu kredit sebelum dikirim ke sink. Mode prod mematikan debug output. | Mematikan Talker dev tools secara compile-time di flavor `prod`. |
| **I-04** | Kebocoran data rahasia melalui clipboard sistem. | Aplikasi lain membaca pasteboard sistem setelah user menyalin data sensitif. | `ClipboardGuard` (`lib/core/security/privacy/clipboard_guard.dart`) membersihkan clipboard secara otomatis setelah 30 detik. | Form password wajib memakai `enableSuggestions: false`. |

### 2.5. Denial of Service (Gangguan Layanan)
| ID | Skenario Ancaman | Vektor Serangan | Mitigasi di Fluttea | Residual Risk / Rekomendasi Backend |
|---|---|---|---|---|
| **D-01** | Zip Bomb saat mengolah berkas arsip. | File berukuran 1MB diekstrak menjadi 10GB untuk menghabiskan penyimpanan perangkat. | `ArchiveGuard` membatasi ukuran uncompressed maksimal (`maxUncompressedSize: 50MB`) dan rasio kompresi (`maxCompressionRatio: 100`). | Server harus menerapkan batasan ukuran body request di reverse proxy gateway. |
| **D-02** | Replay Attack membanjiri antrean server. | Menangkap request sah dan mengirimkannya berulang-ulang untuk menghabiskan kuota. | `HmacSigner` header `X-Timestamp` dan `X-Nonce` ditolak bila drift waktu > 300 detik atau nonce telah dipakai. | Backend wajib mengimplementasikan Redis nonce blacklist (TTL 300s). |

### 2.6. Elevation of Privilege (Eskalasi Hak Akses)
| ID | Skenario Ancaman | Vektor Serangan | Mitigasi di Fluttea | Residual Risk / Rekomendasi Backend |
|---|---|---|---|---|
| **E-01** | Eskalasi hak akses pada perangkat yang di-root/jailbreak. | Menembus proteksi sandbox OS Android/iOS untuk mengakses berkas privat aplikasi lain. | RASP signal `isRootedOrJailbroken` dideteksi saat bootstrap; `SecurityPolicy` dapat menghentikan aplikasi (`SecurityVerdict.block` / `wipe`). | Server harus memvalidasi integritas perangkat melalui token Play Integrity API (MEETS_STRONG_INTEGRITY). |

---

## 3. Matriks Sisa Risiko (Residual Risk Matrix)

```
Dampak (Impact)
  ▲
  │   [Sedang]                       [Tinggi]
H │   Frida Memory Hooking *         Zero-Day OS Vulnerability
  │   (Mitigasi: RASP + Obfuscate)   (Mitigasi: Patching OS)
  │
M │   [Rendah]                       [Sedang]
  │   Offline Binary Reverse Eng     Device Theft (Tanpa PIN OS)
  │   (Mitigasi: Obfuscate Symbols)  (Mitigasi: Keystore Non-Exportable)
  │
L │   [Sangat Rendah]                [Rendah]
  │   MIME Type Spoofing             Log Interception di Debug
  │   (Mitigasi: Magic Bytes)        (Mitigasi: PII Masking)
  └──────────────────────────────────────────────────────────►
     Rendah (Low)                    Tinggi (High)   Kemungkinan (Likelihood)
```

*\*Catatan: Sesuai prinsip pertahanan mendalam (Defense-in-Depth), kontrol pada sisi klien dirancang untuk menaikkan biaya serangan penyerang (*raise the attack cost*). Keamanan akhir dan otorisasi data transaksi mutlak berada pada validasi backend.*

