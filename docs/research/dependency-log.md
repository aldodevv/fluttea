# Dependency Log

Data: `raw-snapshot.md` (2026-11-14). Kolom: umur = hari sejak rilis terakhir; SPM = tag `is:swiftpm-plugin` (paket non-plugin ditulis n/a; paket federated dicek pada implementasi iOS-nya). Advisory OSV pada paket terpilih: **tidak ada yang berlaku pada versi terbaru** (advisory `dio` sudah fix di 5.0.0, `dio_http2_adapter` di 2.8.0, `http` di 0.13.3).
Versi dipasang dengan `^` mengikuti hasil `flutter pub add` saat build, lalu dibekukan di `pubspec.lock`.

## A. Runtime (22 terpasang pada fase 1; Firebase menyusul)
| Paket | Versi | Umur | Publisher | SPM | Alasan |
|---|---|---|---|---|---|
| flutter_riverpod | 3.5.0 | 7 | dash-overflow.net | n/a | State + DI + scope + autoDispose, 4,3 jt unduhan/bln. Tanpa codegen |
| go_router | 18.1.4 | 4 | flutter.dev | n/a | Router resmi, deep link, redirect/guard |
| dio | 5.11.1 | 71 | flutter.cn | n/a | HTTP client yang diminta; interceptor, adapter |
| talker | 5.2.0 | 20 | frezycode.com | n/a | Log terstruktur + riwayat. Dependensi minimal (1) |
| talker_flutter | 5.2.0 | 20 | frezycode.com | n/a | UI log untuk DevTools (non-prod) |
| cryptography | 2.9.0 | 357 | dint.dev | n/a | AES-GCM, ChaCha20, X25519, HKDF, Argon2id, Ed25519. Skor pub 130/160: cek rincian saat build |
| material_ui | 1.11.0 | 5 | flutter.dev | n/a | **Material resmi terpisah dari SDK sejak Flutter 3.47**; `package:flutter/material.dart` deprecated. Membawa `cupertino_ui` |
| crypto | 3.0.8 | 18 | dart.dev | n/a | SHA-2, HMAC dasar, tanpa dependensi |
| asn1lib | 1.6.8 | 16 | — | n/a | Parse DER untuk SPKI pin; 0 dependensi, 2,4 jt unduhan/bln |
| flutter_secure_storage | 11.2.0 | 58 | steenbakker.dev | Y | Keychain/Keystore, versi stabil (nyx memakai beta) |
| shared_preferences | 2.5.6 | 39 | flutter.dev | Y | Preferensi non-sensitif |
| local_auth | 3.0.2 | 127 | flutter.dev | Y | Biometrik resmi |
| package_info_plus | 10.2.2 | 43 | fluttercommunity.dev | Y | Versi/build |
| device_info_plus | 13.3.0 | 43 | fluttercommunity.dev | Y | Info perangkat untuk header/atestasi |
| connectivity_plus | 7.3.2 | 43 | fluttercommunity.dev | Y | Status jaringan (menggantikan network_info_plus di nyx) |
| firebase_core | 5.1.0 | 21 | firebase.google.com | Y | Lihat `firebase.md` |
| firebase_remote_config | 7.0.1 | 21 | firebase.google.com | Y | |
| firebase_messaging | 17.0.1 | 21 | firebase.google.com | Y | |
| firebase_crashlytics | 6.0.1 | 21 | firebase.google.com | Y | |
| flutter_local_notifications | 23.0.2 | 0 | dexterx.dev | Y | Notifikasi foreground; rilis hari ini → pin saat build, cek issue |
| freezed_annotation | 3.1.0 | 499 | dash-overflow.net | n/a | Pasangan `freezed` 4 (pinned `3.1.0` oleh freezed itu sendiri) |
| json_annotation | 4.12.0 | 182 | google.dev | n/a | |
| intl | 0.20.3 | 141 | dart.dev | n/a | l10n resmi (ARB + `gen_l10n`) |
| flutter_localizations | SDK | — | flutter.dev | n/a | |

## B. Dev (9)
| Paket | Versi | Catatan |
|---|---|---|
| build_runner | 2.17.1 | Untuk freezed, json_serializable, go_router_builder |
| freezed | 4.0.3 | Butuh Dart ≥ 3.13, analyzer 14 |
| go_router_builder | 4.5.3 | Type-safe route generation (`@TypedGoRoute` / `GoRouteData`) untuk `go_router` 18.x |
| json_serializable | 6.15.2 | |
| pigeon | 30.0.2 | Kontrak native untuk `fluttea_security` (flutter.dev) |
| very_good_analysis | 11.0.0 | Lint ketat; matikan `public_member_api_docs` |
| mocktail | 1.0.5 | |
| flutter_test, integration_test | SDK | |

## C. Opsional (per project, tetap lewat filter)
| Paket | Versi | Kapan |
|---|---|---|
| cryptography_flutter | 2.3.4 | Akselerasi native. **Dikeluarkan dari default:** plugin masih memakai Kotlin Gradle Plugin; build Flutter 3.50 memberi peringatan bahwa versi Flutter mendatang akan gagal build. Pakai hanya bila performa kripto terukur butuh, dan setelah plugin migrasi ke Built-in Kotlin |
| firebase_app_check | 0.5.1 | Backend memakai layanan Firebase |
| freerasp | 8.3.0 (9.0.0 terlalu baru) | Mau RASP komersial-lite; cek telemetri |
| dio_http2_adapter | 2.9.0 | Backend HTTP/2 multiplex |
| cupertino_http / cronet_http | 3.1.1 / 1.10.1 | Stack jaringan native; pinning native |
| native_dio_adapter | 1.8.0 | Adapter native untuk Dio |
| cached_network_image | 4.0.7 | Banyak gambar jaringan |
| flutter_svg | 2.4.0 | Aset SVG |
| url_launcher | 6.3.3 | Buka URL |
| permission_handler | 13.0.2 | Banyak izin runtime |
| image_picker 1.2.4 / file_picker 13.3.3 | | Unggah media/file |
| share_plus | 13.3.1 | 14 dependensi: hanya bila perlu |
| app_links | 7.2.2 | Deep link / universal link |
| skeletonizer 3.0.0, lottie 3.8.2 | | Loading/animasi |

## D. Ditolak
| Paket | Alasan |
|---|---|
| http_certificate_pinning 3.0.2 | Pengecekan lewat koneksi terpisah (bukan koneksi request); 36 rb unduhan/bln. Diganti pinning di `HttpClient` |
| ssl_pinning_plugin 2.0.0 | 2046 hari tanpa rilis, tanpa publisher |
| flutter_jailbreak_detection 1.10.0 | 1402 hari, tanpa SPM |
| pretty_dio_logger 1.4.0 | 845 hari; tidak ada redaksi |
| dio_smart_retry 7.0.1 | 752 hari; retry ditulis sendiri (±60 baris, tahu idempotensi dan backoff) |
| easy_localization 3.0.8 | 477 hari, tanpa publisher; diganti `gen_l10n` resmi |
| encrypt 5.0.3 | 1152 hari, tanpa publisher |
| fast_rsa 3.8.6 | Tanpa SPM, 100 poin, 7 dependensi. RSA bila diwajibkan backend: `pointycastle` (pure Dart) |
| pointycastle 4.0.0 | 632 hari: hanya bila RSA/EC khusus wajib |
| dargon2_flutter / argon2 | 1245 / 1975 hari. Argon2id sudah ada di `cryptography` |
| secure_application 4.1.0 | 606 hari, tanpa SPM. Diganti `ScreenProtector` native di `fluttea_security` |
| flutter_windowmanager 0.2.0 | 1905 hari. `FLAG_SECURE` di modul native |
| play_integrity_flutter 0.0.1 | 0.0.x, 1391 hari. Atestasi di modul native |
| get 4.7.3, mobx, watch_it, solidart, signals, state_beacon | Tidak perlu: Riverpod sudah menutup kebutuhan; mengurangi ragam |
| flutter_bloc 9.1.1 / bloc | Boilerplate tinggi (alasan utama kamu), 560 hari |
| provider 6.1.5+1 | 451 hari; penerusnya Riverpod |
| auto_route 11.2.0 | Codegen berat (nyx: 6272 baris generated) |
| get_it + injectable | Digantikan Riverpod |
| dartz | Diganti `Result<T>` buatan sendiri (sealed class) |
| flutter_flavorizr 2.6.0 | Tidak jadi dependensi tetap. **Dipakai satu kali** (processor `android:*`, `ios:xcconfig/buildTargets/schema/plist`) untuk membuat flavor dev/prod lalu dihapus dari pubspec |
| flutter_launcher_icons 0.14.4 | 521 hari; ikon dibuat sekali (script/alat satu kali) |
| custom_lint / riverpod_lint | 430 hari / tambahan analyzer; tunda sampai stabil |
| dio_cache_interceptor 4.0.7 | Opsional bila butuh HTTP cache; belum default |
| retrofit 4.10.0, chopper 8.7.1 | Codegen API client; `ApiClient` + `freezed` cukup |

## E. Overlap yang sudah dibersihkan dari nyx
`fast_rsa`+`cryptography` → `cryptography` (tanpa `cryptography_flutter` default); `connectivity_plus`+`network_info_plus` → `connectivity_plus`; `rive`+`lottie`+`avatar_glow` → opsional `lottie`; `firebase_*` 6 → 4; `flutter_cache_manager`+`cached_network_image` → opsional satu; `get_it`+`injectable`+`flutter_bloc`+`bloc_concurrency`+`equatable`+`dartz` → Riverpod + freezed + `Result<T>`.

## F. Yang wajib diulang saat build
Semua versi di atas adalah snapshot. Saat `flutter pub add`, bandingkan hasilnya dengan tabel ini; perbedaan ≥ 1 minor dicatat. Jalankan ulang `osv-scanner --lockfile=pubspec.lock` dan Snyk SCA setelah `pub get`.
