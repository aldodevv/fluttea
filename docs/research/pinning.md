# Pinning — Desain yang Bekerja di Level HTTP

## Fakta terverifikasi
- `IOHttpClientAdapter.validateCertificate` dipanggil **setelah** `request.close()` dan response diterima (`dio/lib/src/adapters/io_adapter.dart`, baris ±192). Header dan body request sudah terkirim. Pola README Dio (fingerprint di `validateCertificate`) hanya mendeteksi, tidak mencegah kebocoran request.
- Dokumentasi Dio sendiri: callback ini dipanggil hanya bila `SecurityContext` dan `badCertificateCallback` menerima rantai; yang dievaluasi adalah leaf.
- `badCertificateCallback` dipanggil **saat handshake**, sebelum request dikirim, dan menerima `X509Certificate` (leaf, ada `.der`). Bila `SecurityContext(withTrustedRoots:false)`, semua sertifikat dianggap tidak tepercaya sehingga callback selalu dipanggil.
- `HttpClient.connectionFactory` hanya membuat socket TCP; untuk HTTPS, TLS dilakukan HttpClient setelahnya, jadi tidak bisa dipakai untuk memeriksa sertifikat.
- `dart:io` tidak mengambil pin dari `network_security_config` Android atau `NSPinnedDomains` iOS (**diverifikasi lewat tes emulator di fase 6**, tidak diasumsikan).
- Paket `http_certificate_pinning` (36 rb unduhan/bulan) memeriksa lewat koneksi terpisah, bukan koneksi yang dipakai request. Ditolak.

## Strategi dan di mana pin ditegakkan

| Strategi | Mekanisme | Sebelum request terkirim? | Rantai CA divalidasi? | Cocok untuk |
|---|---|---|---|---|
| `SpkiLeafPin` | `withTrustedRoots:false` + `badCertificateCallback` hitung SHA-256 SPKI leaf, cocokkan, cek tanggal | Ya | Tidak (kunci = identitas), jadi wajib pin per-host + ≥ 2 pin | Kunci leaf stabil |
| `CertLeafPin` | sama, hash seluruh DER | Ya | Tidak | Server sendiri, sertifikat jarang diganti |
| `CaPin` (intermediate/root) | `SecurityContext(withTrustedRoots:false)` + `setTrustedCertificatesBytes(caDer)` | Ya | Ya (hostname, tanggal, rantai) | CA publik, leaf sering rotasi |
| `PrivateCaTrust` | sama dengan `CaPin` dengan CA internal | Ya | Ya | Backend internal |
| `MutualTls` | `useCertificateChainBytes` + `usePrivateKeyBytes` (kunci dari secure storage) | Ya | Ya | Zero-trust / B2B |
| `DynamicPins` | set pin dari Remote Config/endpoint, **ditandatangani** (Ed25519), pin awal tetap compile-time | Ya | Mengikuti strategi dasar | Rotasi tanpa rilis |
| `PostResponseGuard` | `validateCertificate` sebagai lapisan kedua (defense in depth) | Tidak | Tidak | Selalu aktif bersama strategi di atas |
| `NativeStackPin` | `NSPinnedDomains` (iOS) / Cronet via adapter native | Ya (OS) | Ya | Hanya bila memakai `cupertino_http`/`cronet_http` |
| `Off` | tanpa pin | — | Ya (trust store OS) | Hanya `kDebugMode` + dev |

`PinSet` menggabungkan beberapa strategi (`all`/`any`) per host: `{ 'api.example.com': PinSet(any: [spkiA, spkiB], also: [CaPin(...)]) }`. Host yang tidak ada di peta = ditolak di prod (fail closed).

## Komponen kode (`core/security/pinning/`)
- `spki.dart`: ekstrak SubjectPublicKeyInfo dari DER (`asn1lib`), SHA-256 → base64.
- `pin_set.dart`, `pin_strategy.dart` (sealed), satu file per strategi.
- `pinned_http_client_factory.dart`: membangun `HttpClient` (SecurityContext + callback) dari `PinSet`.
- `pinning_adapter.dart`: `IOHttpClientAdapter(createHttpClient: …, validateCertificate: …)`.
- `tool/spki_pin.dart`: CLI `dart run tool/spki_pin.dart host:443` mencetak pin SPKI untuk leaf dan seluruh rantai (cara menghitung pin saat rotasi).

## Pengujian wajib (fase 6)
Server HTTPS lokal (Dart `HttpServer.bindSecure`) dengan tiga sertifikat uji: benar, salah kunci, CA tidak dikenal. Tiap strategi diuji:
1. Pin benar → request sukses.
2. Pin salah → `DioException.badCertificate` dan **server tidak menerima satu byte pun request** (assert di sisi server).
3. Sertifikat kedaluwarsa → ditolak.
4. Rotasi: pin cadangan menerima, pin utama lama tetap diterima selama transisi.
5. Proxy MITM (mitmproxy dengan CA yang dipercaya sistem) → ditolak.
6. Uji emulator Android + simulator iOS untuk membuktikan klaim `network_security_config` tidak berlaku pada `dart:io`.

## Referensi untuk diverifikasi ulang via Context7 saat implementasi
Dio `IOHttpClientAdapter`, `dart:io` `SecurityContext`, `HttpClient.badCertificateCallback`, `X509Certificate`.
