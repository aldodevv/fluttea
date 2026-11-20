# ADR 0005: Integrasi Native Security (RASP) Melalui Pigeon Type-Safe IPC

* **Status:** Diterima (Accepted)
* **Tanggal:** 2026-11-15
* **Pengambil Keputusan:** Tim Arsitektur Fluttea & User

---

## Konteks & Masalah
Untuk memenuhi standar OWASP MASVS-RESILIENCE, aplikasi mobile membutuhkan deteksi integritas lingkungan runtime (*Runtime Application Self-Protection / RASP*):
* Deteksi Root / Jailbreak
* Deteksi Hooking Frameworks (Frida, Xposed, Cydia Substrate)
* Deteksi Debugger Attachment
* Deteksi Eksekusi di Emulator / Virtual Machine
* Deteksi Modifikasi Integritas Binary & Unofficial App Store

Solusi umum di Flutter sering kali menggunakan package pihak ketiga komersial atau wrapper community yang memiliki kelemahan:
1. **Kurang Terawat / Breaking Changes:** Banyak package RASP community tidak diupdate sejalan dengan rilis versi Android/iOS terbaru.
2. **Telemetri Tersembunyi:** Beberapa library free-tier (seperti Talsec freeRASP) mengirimkan telemetri metadata perangkat ke server pihak ketiga secara default, yang berpotensi melanggar kepatuhan privasi (GDPR / UU PDP).
3. **Overhead Platform Channel:** Menggunakan `MethodChannel` string-based rentan terhadap typo, minim type-safety, dan sulit di-mock dalam unit test.

## Keputusan
Kami memutuskan untuk:
1. Mengembangkan modul native sendiri di `packages/fluttea_security/` dengan antarmuka yang di-generate menggunakan **Pigeon** (`security_api.dart`).
2. Pigeon secara otomatis menghasilkan kode typed contract untuk Dart, Kotlin (Android), dan Swift (iOS) tanpa refleksi runtime.
3. Menyediakan abstraksi `SecurityProvider` dengan dua implementasi:
   * `NativeSecurityProvider` (Default): Menggunakan Pigeon native IPC ke sistem OS.
   * `MockSecurityProvider`: Untuk unit test dan simulasi DevTools RASP tanpa membutuhkan perangkat fisik.
4. Menghubungkan seluruh sinyal keamanan ke `SecurityGate` yang mengevaluasi `SecurityPolicy` berjenjang (`allow`, `warn`, `restrict`, `block`, `wipe`).

## Konsekuensi

### Positif:
1. **Type-Safety Penuh & Zero Typo:** Interface antara Dart, Kotlin, dan Swift divalidasi saat waktu kompilasi.
2. **Kemandirian Penuh & Zero Telemetry:** Kontrol penuh atas kode native tanpa risiko kebocoran data pengguna ke analitik eksternal.
3. **Mudah Diuji (100% Testable):** Sinyal keamanan dapat di-mock dan diuji perilakunya di level widget test dan integration test tanpa membutuhkan perangkat yang di-root sungguhan.

### Negatif / Mitigasi:
* *Kekurangan:* Menuntut pemeliharaan kode native Kotlin dan Swift di dalam sub-package `packages/fluttea_security/`.
* *Mitigasi:* Kode native sangat ramping, terisolasi, dan arsitekturnya modular sehingga mudah diperbarui bila API platform berkembang.

