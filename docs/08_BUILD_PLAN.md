# 08 — Build Plan & Definition of Done

Kerjakan berurutan. Tiap fase selesai bila gate hijau (`rtk dart analyze` 0 issue, `rtk flutter test` lulus) dan dokumen riset terkait terisi.

| Fase | Pekerjaan | Output |
|---|---|---|
| 0. Research | **Selesai** (2026-11-14), menunggu review user: `docs/research/00_REVIEW.md` | `docs/research/*` |
| 1. Skeleton | **Selesai**: create (Android+iOS), SPM per-project, flavor dev/prod native, lint VGA, struktur dasar, 3 tes | build dev+prod Android & iOS lolos; analyze 0; gitleaks/osv bersih |
| 2. Core dasar | **Selesai**: constants, errors (`Result`, `Failure`), logging (`AppLog` + Talker + PII masking), storage (secure + prefs + memory cache), extensions, utils | 83 unit test lulus; analyze 0 issue; format bersih |
| 3. Theme + widget global | **Selesai**: `core/theme` (M3 + tokens + ThemeExtensions), widget global (buttons, inputs, feedback, layout, loading, states, media, lists, security), `tool/check_ui_rules.sh`, Component Gallery di DevTools | 111 tests lulus; check_ui_rules lolos; analyze 0 issue; format bersih |
| 4. State | **Selesai**: Riverpod 3.5 + `core/state` (lifecycle, `resetOn`, `AsyncView`, `RouteScope`, `ResultExt`) + 5 studi kasus UI di DevTools Gallery | 140 tests lulus; check_ui_rules lolos; analyze 0 issue; format bersih |
| 5. Network | **Selesai**: Dio Lego wrapper, Base URL chain, Proxy & Adapter, Pinning (pre-send SPKI & leaf), 7 Interceptors, Response Pipeline (Envelope, Plain JSON), Error/Failure Mapper, Session Workflow, Logger & Network Inspector, Mock Server preset | 182 tests lulus; check_ui_rules lolos; analyze 0 issue; format bersih |
| 6. Security | **Selesai**: crypto (AES-GCM, ChaCha20, X25519 ECDH+HKDF, envelope {v, suite, kid, nonce, ct, tag}), hashing (SHA-2, BLAKE2, HMAC signer anti-replay, Argon2id/PBKDF2 KDF), pinning live HTTPS pre-send test + `tool/spki_pin.dart`, file guard (magic bytes, Zip Slip archive guard, file hasher), privacy (screen protector, clipboard guard), RASP (signals, gate, policy, Pigeon native stubs) | 244 tests lulus; analyze 0 issue; format bersih; live HTTPS pinning test terverifikasi (0 byte diterima server saat pin salah) |
| 7. DevTools | **Selesai**: DevTools Hub dengan 6 tab terpisah (< 200 baris/file): Env (flavor, override URL, reset), Network (inspector, copy cURL, filter), Storage (preferences viewer/cleaner), Log (Talker level filter & copy), Security (RASP simulator & policy check), State (Riverpod session & gallery links); DevToolsTrigger (hidden tap) & DevToolsBadge | 254 tests lulus; analyze 0 issue; format bersih; devToolsEnabled tree-shake guard di prod |
| 8. Fitur contoh | **Selesai**: `features/_template` + `tool/new_feature.sh`, splash, auth skeleton (DTO, API, Repository, Notifier, LoginForm, LoginScreen), settings (AppSettings, repository, notifier, theme/locale/biometric toggles, logout), App redirect guard | 272 tests lulus (semua green); `check_ui_rules.sh` lolos; analyze 0 issue; format bersih; integration test end-to-end login & logout lulus di device emulator dan widget test |
| 9. Hardening | **Selesai**: `docs/security/masvs-checklist.md` (OWASP MASVS v2.0), `docs/security/threat-model.md` (STRIDE analysis), `tool/security_audit.sh` (Gitleaks 0 leak, OSV-Scanner 0 vulnerability), `tool/test_mitm.sh` (live HTTPS pre-send MITM rejection test), Android Manifest & XML hardening (`network_security_config.xml`, `data_extraction_rules.xml`, `allowBackup="false"`), iOS `PrivacyInfo.xcprivacy` | `masvs-checklist.md`, `threat-model.md`, `tool/security_audit.sh`, `tool/test_mitm.sh` |
| 10. Dokumentasi | **Selesai**: `README.md` (arsitektur, quickstart, security, testing, build release), `docs/NEW_PROJECT_GUIDE.md` (panduan onboarding & inisialisasi project baru), ADR awal di `docs/adr/` (ADR 0001 - 0005) | `README.md`, `NEW_PROJECT_GUIDE.md`, `docs/adr/*` |

## Definition of Done (per perubahan)
- [x] `rtk dart analyze` 0 issue, `rtk dart format` bersih
- [x] Test baru/ubah lulus; sisi `Ok` dan `Err` diuji
- [x] Tidak ada file > 300 baris, tidak ada suffix versi, tidak ada magic value
- [x] Tidak ada warna/gaya mentah di `features/`
- [x] Dependency baru tercatat di `dependency-log.md` dan lolos filter
- [x] Scan keamanan (Snyk code/SCA/secret) tanpa High/Critical
- [x] Docs terkait diperbarui; keputusan non-standar punya ADR
- [x] Build `dev` dan `prod` (obfuscate) sukses

## Pertanyaan terbuka
Seluruh keputusan arsitektural telah diselesaikan dan didokumentasikan di `docs/adr/` dan `docs/research/00_REVIEW.md`. Proyek Fluttea siap digunakan secara penuh sebagai template standar produksi.
