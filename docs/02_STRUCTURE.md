# 02 — Struktur Folder

Prinsip: **feature-first, core dikelompokkan per kebutuhan, satu file satu tanggung jawab, maksimum 300 baris**. Template hanya berisi yang standar. Detail fitur ditambah per project.

```
fluttea/
├─ AGENTS.md
├─ docs/                      # panduan + research/ + adr/
├─ assets/
│  ├─ images/  icons/  fonts/  translations/    # satu level, tanpa v2
├─ lib/
│  ├─ main.dart               # runApp(bootstrap) — tidak dipakai langsung
│  ├─ main_dev.dart           # AppFlavor.dev lalu bootstrap()
│  ├─ main_prod.dart          # AppFlavor.prod lalu bootstrap()
│  ├─ app/
│  │  ├─ app.dart             # MaterialApp.router, tema, locale
│  │  ├─ bootstrap.dart       # init berurutan: flavor, storage, security, network, state
│  │  ├─ flavor.dart          # enum AppFlavor + AppEnv (satu-satunya switch flavor)
│  │  ├─ router/              # go_router: routes.dart, guards/, observers/
│  │  └─ providers.dart       # provider global = DI (Riverpod, lihat 05)
│  ├─ core/
│  │  ├─ constants/           # HANYA const (lihat 03)
│  │  ├─ utils/               # fungsi murni per topik (lihat 03)
│  │  ├─ extensions/          # extension per tipe: context_x, string_x, num_x, date_x
│  │  ├─ theme/               # ThemeData, ThemeExtension, tokens
│  │  ├─ widgets/             # widget global (lihat 03)
│  │  ├─ network/             # Dio lego (lihat 04)
│  │  ├─ security/            # crypto, pinning, rasp, file_scan (lihat 06)
│  │  ├─ storage/             # secure/, prefs/, cache/
│  │  ├─ state/               # lifecycle, reset policy (Riverpod, lihat 05)
│  │  ├─ errors/              # Failure, Result, error mapper
│  │  ├─ services/            # lifecycle, connectivity, device_info, biometric, permission
│  │  ├─ logging/             # AppLog (tag, level, sink)
│  │  ├─ devtools/            # panel debug: tab_network, tab_env, tab_storage, tab_log
│  │  └─ l10n/                # localization helper + keys
│  └─ features/
│     └─ <feature>/
│        ├─ data/             # dto/, <feature>_api.dart, <feature>_repository.dart
│        ├─ domain/           # model/ (entity), use case hanya jika logika > 1 repository
│        ├─ state/            # <feature>_notifier.dart + provider (satu file)
│        └─ presentation/
│           ├─ screens/       # <feature>_screen.dart
│           └─ widgets/       # widget lokal fitur
├─ packages/
│  └─ fluttea_security/       # plugin lokal Kotlin + Swift (Pigeon), lihat research/native-security.md
├─ test/                      # mirror lib/
├─ integration_test/
├─ android/  ios/             # SPM aktif, flavor dev/prod
└─ tool/                      # script: check_size.sh, audit.sh, gen_icons.sh
```

## Fitur contoh (template menyertakan 3 saja)
`features/splash`, `features/auth` (login skeleton + session), `features/settings` (bahasa, tema, DevTools). Sisanya ditambah project.

## Aturan
- `features/*` boleh import `core/*` dan `app/*`-nya tidak. `core/*` tidak boleh import `features/*`. Antar fitur: hanya via `domain/model` atau lewat router, tidak langsung ke `data`/`state` fitur lain.
- `domain/` diisi hanya bila ada model/aturan bisnis. Jangan membuat `usecase` pass-through.
- Repository mengembalikan `Result<T>`. DTO tinggal di `data/dto`, UI tidak pernah melihat DTO.
- Penamaan: file `snake_case`; `*_screen.dart`, `*_notifier.dart`, `*_repository.dart`, `*_dto.dart`, `*_api.dart`. Tidak ada `helper.dart`/`manager.dart`/`common.dart` generik.
- Barrel file (`export`) hanya satu per folder besar di `core/` bila perlu; tidak di `features/`.
- Satu class publik per file, kecuali `sealed` family.
- `part`/`part of` hanya untuk generated.
- Import: relatif di dalam satu feature, `package:` lintas feature/core. Aktifkan lint `always_use_package_imports` atau `prefer_relative_imports` (pilih satu, konsisten).
- Asset path hanya didefinisikan di `core/constants/asset_paths.dart`.

## Menambah fitur
1. Salin `features/_template/` (disertakan di template, berisi file kosong terstruktur).
2. Rename, daftarkan route di `app/router/routes.dart`, daftarkan provider global bila perlu di `app/providers.dart`.
3. Tambah test mirror di `test/features/<nama>/`.
