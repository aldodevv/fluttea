# 00 — Lessons dari Nyx

Sumber: `/Users/aldodevv/code/work/nyx` (921 file di `lib/`, ±125k baris termasuk generated). Temuan di bawah diverifikasi dari kode dan pubspec. Template ini harus menghindari semuanya.

## Yang berantakan → aturan Fluttea

| Temuan di Nyx | Dampak | Aturan Fluttea |
|---|---|---|
| `widgets/` dan `widgets_v2/`, `pages/` dan `pages_v2/`, `theme.dart` dan `theme_v2.dart`, `transaction` dan `transaction_v2` | Dua sumber kebenaran, tidak jelas mana yang dipakai | Tanpa suffix versi. Refactor in-place, hapus yang lama |
| Layer-first: `application/ domain/ infrastructure/ presentation/` masing-masing berisi ±35 nama fitur yang sama | Satu fitur tersebar di 4 folder, sulit dihapus/dipindah | Feature-first: `features/<nama>/` berisi semua layer fitur itu |
| `core/` datar: 5 `firebase_options_*.dart`, `biometric_*` berserakan, `safe.dart`, `guard/` | Tidak ada pengelompokan | `core/` dibagi per kebutuhan (`network/ security/ storage/ ...`) |
| `InfrastructureConst` satu class 231 baris: key URL, SHA pin, RC, pentest, dsb. bercampur. Ada `const.dart` kedua di presentation | Sulit dicari, mudah bentrok | `core/constants/` dipecah per topik, satu file satu topik |
| `DioApp` static singleton 609 baris: switch flavor untuk base URL, pinning, adapter, 14 interceptor dalam satu list, ambil `BuildContext` dari navigator via get_it | Tidak bisa dites, tidak bisa dibongkar-pasang | Dio di-compose dari modul kecil (lihat `04_NETWORK.md`) |
| `validateStatus: (_) => true`, dev memakai `badCertificateCallback => true` | Error tersembunyi, risiko MITM bocor ke build lain | Status diproses handler eksplisit; bypass cert hanya `kDebugMode` + flavor dev + terlihat di DevTools |
| Pin SHA dan URL dari `.env` yang dibundle sebagai asset | Asset bisa diekstrak dari APK/IPA | Tidak ada rahasia di bundle. Pin = public data, boleh di-compile; rahasia nyata hanya dari server |
| 5 flavor (dev/test/preploy/pilot/prod): 5 `main_*.dart`, 5 firebase options, 5 icon yaml, 5 splash yaml, dynatrace per flavor | Maintenance berat | 2 flavor (dev, prod). Base URL bisa diubah lewat DevTools, bukan flavor baru |
| `dev_tools_app.dart` 1044 baris, repository 1000–1576 baris, page 700+ baris | God file | Batas 300 baris, DevTools dipecah per tab |
| Stack codegen berat: auto_route + injectable + get_it + flutter_gen + json_serializable + build_runner | Build lambat, generated 6272 baris di `routes.gr.dart` | Minim codegen. go_router tanpa generator, DI manual |
| Dependency: git private (`date_picker_plus`), fork (`cryptography_*_plus`), beta (`flutter_secure_storage ^10.0.0-beta`), `dependency_overrides`, versi `0.0.x` (`convert_widget_to_image`, `scroll_screenshot`, `smooth_chucker`, `did_change_authlocal`) | Risiko supply chain, mudah mati saat upgrade SDK | Hanya stable, publisher jelas, terawat. Git/fork/override dilarang tanpa ADR |
| Fungsi tumpang tindih: `fast_rsa` + `cryptography`; `connectivity_plus` + `network_info_plus`; `rive` + `lottie` + `avatar_glow`; `firebase_*` ×6; 3 pustaka image/screenshot | Ukuran app membengkak | Satu kebutuhan = satu package. Ada audit overlap di research |
| Banyak `.DS_Store`, `gradle-dependencies.log`, `build/` dan keystore (`*.jks`) ada di tree project | Kebocoran/kotor | `.gitignore` ketat dari hari pertama |

## Yang bagus dan dipertahankan
- Kontrak "API tidak melempar": `Either<Failure, T>` → ganti ke `Result<T>` sealed class (tanpa `dartz`).
- Interceptor dipisah per file (encrypt, decrypt, token, logger, maintenance, time sync).
- `AGENTS.md` dengan boundaries (allowed / ask first / never), `plans/` sebagai docs, i18n standard, test mirror struktur `lib/`.
- Guard keamanan runtime: jailbreak/root, VPN, auto-date-time, time skew, secure application (screen privacy).
- Entry point flavor tipis yang hanya set flavor lalu memanggil `bootstrap()`.
- Design token (`SizesApp`, `ColorsApp`) — niatnya benar, tetapi tidak dipaksa lewat `ThemeData`.

## Cara memakai dokumen ini
Setiap PR/perubahan harus lolos cek: "Apakah ini mengulang salah satu baris tabel di atas?"
