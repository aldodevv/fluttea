# ADR 0002: Pre-Send TLS SPKI Pinning vs Post-Response Validation

* **Status:** Diterima (Accepted)
* **Tanggal:** 2026-11-14
* **Pengambil Keputusan:** Tim Arsitektur Fluttea & User

---

## Konteks & Masalah
Banyak panduan dan package Flutter (termasuk contoh default Dio) menyarankan SSL Pinning melalui callback `validateCertificate` pada `IOHttpClientAdapter`.

Namun, audit mendalam terhadap source code `dart:io` dan Dio mengungkapkan cacat keamanan fatal (*vulnerability*):
1. **`validateCertificate` berjalan setelah handshake selesai dan response diterima oleh soket.**
2. Artinya, **request HTTP (termasuk header Authorization, cookie sesi, dan body payload sensitif) SUDAH TERKIRIM ke kabel jaringan** sebelum verifikasi pinning dievaluasi.
3. Jika terjadi serangan Man-In-The-Middle (MITM) aktif dengan sertifikat palsu yang dipercayai oleh root CA lokal perangkat, penyerang telah berhasil menangkap data request secara plaintext sebelum koneksi diputus oleh client!

Selain itu, pinning berbasis OS native (`network_security_config` Android dan `NSPinnedDomains` iOS) tidak berlaku untuk `dart:io` karena runtime Dart menyertakan stack BoringSSL mandiri, bukan stack HTTP native OS (kecuali memakai adapter native seperti `cronet_http` atau `cupertino_http`).

## Keputusan
Kami memutuskan untuk menegakkan **Pre-Send TLS SPKI Pinning** murni pada layer socket handshake:
1. Menggunakan `SecurityContext(withTrustedRoots: false)` dipadukan dengan `badCertificateCallback` di level `HttpClient` Dart.
2. Evaluasi pinning dilakukan secara deterministik pada callback handshake TLS: Subject Public Key Info (SPKI) SHA-256 base64 diverifikasi **SEBELUM** byte HTTP request pertama diizinkan keluar dari socket.
3. Mendukung primary SPKI pin dan minimal 1 backup SPKI pin untuk menjamin rotasi sertifikat berkala tanpa outage.

## Konsekuensi

### Positif:
1. **Keamanan Maksimal (Zero-Leakage):** Saat diserang oleh proxy MITM yang menyuntikkan sertifikat palsu, socket TLS langsung di-abort seketika. Terbukti melalui automated test `test/core/security/pinning_live_test.dart` bahwa server/proxy penyerang menerima tepat **0 bytes data**.
2. **Tidak Bergantung pada Plugin Pihak Ketiga:** Mengeliminasi dependency plugin SSL pinning eksternal yang sering tidak terawat atau memicu runtime crash pada versi Flutter baru.
3. **Fleksibilitas Rotasi:** Format SPKI mengekstrak kunci publik kriptografis, sehingga renewal sertifikat dengan CSR/keypair yang sama tidak merusak pinning aplikasi.

### Negatif / Mitigasi:
* *Kekurangan:* `withTrustedRoots: false` mengharuskan domain tujuan memiliki aturan pinning eksplisit.
* *Mitigasi:* Disediakan `PinSet` dengan rule berbasis host, fallback dev mode di flavor `dev` (hanya `kDebugMode`), dan CLI extractor `tool/spki_pin.dart` untuk mempermudah operasional tim dev/devops.

