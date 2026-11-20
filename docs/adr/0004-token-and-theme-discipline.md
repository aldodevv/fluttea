# ADR 0004: Penegakan Token Palette & Larangan Nilai Mentah pada UI

* **Status:** Diterima (Accepted)
* **Tanggal:** 2026-11-15
* **Pengambil Keputusan:** Tim Arsitektur Fluttea & User

---

## Konteks & Masalah
Masalah klasik yang terjadi pada proyek Flutter berjangka panjang (seperti pengalaman pada template Nyx):
* Developer menulis `Colors.blue`, `Color(0xFF123456)`, atau `fontSize: 16` secara acak di dalam file widget fitur.
* Ketika fitur Dark Mode diaktifkan, warna-warna mentah ini tidak beradaptasi, menyebabkan teks tidak terbaca (misal teks hitam di latar gelap).
* Saat tim desain melakukan pembaruan design system (rebranding/token update), ribuan baris kode di puluhan modul harus diubah secara manual.

## Keputusan
Kami menetapkan **aturan keras tanpa kompromi** untuk penulisan antarmuka di `lib/features/`:
1. **Dilarang memakai `Colors.xxx`:** Semua warna wajib diakses melalui `context.colors` (Material 3 `ColorScheme`) atau token semantik `context.statusColors`.
2. **Dilarang memakai `Color(0x...)` mentah di dalam fitur:** Definisi warna heksadesimal hanya diizinkan di dalam `core/theme/tokens/palette.dart`.
3. **Dilarang memakai `fontSize:` angka mentah:** Ukuran dan bobot teks wajib menggunakan `context.text.*` (Material 3 `TextTheme`).
4. **Dilarang memakai padding / margin angka acak:** Semua jarak antar komponen wajib menggunakan token `Spacing.*` (`Spacing.xs`, `sm`, `md`, `lg`, `xl`).
5. **Import UI:** Menggunakan `package:material_ui/material_ui.dart` (ekspor M3 terkontrol), bukan `flutter/material.dart` langsung.
6. **Otomasi Pemeriksaan (Linter Guard):** Dibuat skrip validasi shell `tool/check_ui_rules.sh` yang otomatis memblokir build dan commit jika mendeteksi pelanggaran warna atau font mentah di `lib/features/`.

## Konsekuensi

### Positif:
1. **Dukungan Dark Mode Otomatis 100%:** Seluruh komponen UI fitur otomatis beralih antara tema terang dan gelap secara sempurna tanpa penyesuaian manual.
2. **Design System Konsisten:** Konsistensi ritme visual (spasi, tipografi, kontras warna) terjamin di seluruh aplikasi.
3. **Audit Otomatis & Cepat:** Script `./tool/check_ui_rules.sh` berjalan dalam hitungan milidetik dan terintegrasi di dalam pipeline CI / pre-commit hook.

### Negatif:
* Developer baru memerlukan waktu adaptasi singkat untuk membiasakan diri memanggil `context.colors` dan `context.text` daripada menggunakan `Colors` langsung.

