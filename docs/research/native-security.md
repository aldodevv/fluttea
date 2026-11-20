# Security Checker via Native

## Prinsip
Checker dijalankan di Kotlin/Swift, diekspos ke Dart lewat **Pigeon** (`pigeon` 30.0.2, publisher flutter.dev; kontrak bertipe, bukan string method channel). Berbentuk plugin lokal `packages/fluttea_security` (path dependency, bukan git; SPM-compatible `Package.swift` untuk iOS). Dart hanya mengumpulkan sinyal dan menegakkan `policy`; keputusan final selalu di server (Play Integrity / App Attest).

```
packages/fluttea_security/
├─ pigeons/security_api.dart          # kontrak (sumber kebenaran)
├─ android/src/main/kotlin/.../       # checks/, attestation/, privacy/
├─ ios/fluttea_security/Sources/      # Checks/, Attestation/, Privacy/ (Package.swift)
└─ lib/                               # wrapper tipis
```
Dart: `SecurityProvider` (interface) → `NativeSecurityProvider` (default), `FreeRaspProvider` (opsional), `CompositeSecurityProvider` (gabung). Output: `SecurityReport(signals, level)`.

## Cakupan per sinyal

| Sinyal | Android (Kotlin) | iOS (Swift) | Dasar |
|---|---|---|---|
| Root / jailbreak | RootBeer (Apache-2.0, rilis 0.1.2 Maret 2026) + cek `su`, Magisk, `test-keys`, partisi writable | IOSSecuritySuite (rilis 2.3.0 Agu 2026) + cek path, tulis di luar sandbox, `fork()` | Heuristik |
| Hooking (Frida/Xposed/Substrate) | scan `/proc/self/maps`, port Frida, kelas Xposed | `dyld` image list, simbol Substrate | Heuristik |
| Debugger | `Debug.isDebuggerConnected`, `TracerPid` | `sysctl` `P_TRACED` | Heuristik |
| Emulator / simulator | `Build.*`, sensor, properti QEMU | `TARGET_OS_SIMULATOR` + env | Heuristik |
| Integritas app | hash sertifikat tanda tangan (`SigningInfo`) vs nilai tertanam, installer package | validasi `embedded.mobileprovision`, team ID, bundle ID | Deterministik |
| Atestasi perangkat/app | **Play Integrity API** (token → server) | **App Attest / DeviceCheck** (assertion → server) | Terkuat; wajib verifikasi server |
| Layar terkunci | `KeyguardManager.isDeviceSecure` | `LAContext.canEvaluatePolicy(.deviceOwnerAuthentication)` | API OS |
| Hardware key | `KeyInfo.isInsideSecureHardware`, StrongBox | Secure Enclave tersedia | API OS |
| Developer options / ADB | `Settings.Global` | — | API OS |
| VPN / proxy | `NetworkCapabilities.TRANSPORT_VPN`, `http.proxyHost` | `CFNetworkCopySystemProxySettings`, interface `utun*` | API OS |
| Screen capture / recording | `FLAG_SECURE`, `ScreenCaptureCallback` (Android 14+) | `UIScreen.isCaptured`, overlay saat app switcher | API OS |
| Overlay / tapjacking | `filterTouchesWhenObscured`, deteksi accessibility service tak dikenal | — | API OS |
| Mock location | `Location.isMock` | — | API OS |

## Yang tidak bisa disediakan on-device
- Scan malware file yang andal: perlu AV sisi server (ClamAV / VirusTotal API / vendor). Di perangkat hanya `file_guard`: magic bytes, allowlist, batas ukuran, pengecekan arsip, sanitasi gambar, hash SHA-256.
- Deteksi tamper yang tidak bisa di-bypass: tidak ada. Obfuscation + R8 + atestasi server menaikkan biaya, tidak meniadakan risiko.

## freeRASP (opsional)
- Paket `freerasp` 9.0.0 (Talsec, MIT, SPM ✔) rilis 2026-11-13 dengan banyak perubahan breaking; 8.3.0 rilis 2026-11-09. Rekomendasi: tunggu patch pertama 9.x, atau pin 8.3.0.
- Free tier melaporkan telemetri ke Talsec dan butuh konfigurasi (`watcherMail`, hash tanda tangan, bundle/team ID). **Baca kebijakan data mereka dan minta persetujuan kamu** sebelum diaktifkan di app yang menangani data sensitif.
- Adapter berada di `core/security/rasp/freerasp_provider.dart` dan diaktifkan lewat `NetworkProfile`/`SecurityProfile`, tidak masuk default.

## Aturan policy
`SecurityPolicy` memetakan sinyal → aksi `allow | warn | restrict | block | wipeSession`. Default: debug = log saja, prod = `restrict` untuk root/hook/debugger, `block` untuk integritas gagal. Seluruh laporan dikirim ke server lewat header `X-Device-Attest` (token atestasi) agar server menentukan akhirnya.

## Pengujian
- Dart: policy dan komposisi dengan provider palsu.
- Native: unit test Kotlin/Swift per check yang bisa diisolasi.
- Manual: perangkat root (Magisk), perangkat jailbreak, emulator, Frida attach, build yang di-resign. Hasil di `masvs-checklist.md`.
