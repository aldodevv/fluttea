# ADR 0001: Riverpod 3.5 Tanpa Codegen

* **Status:** Diterima (Accepted)
* **Tanggal:** 2026-11-14
* **Pengambil Keputusan:** Tim Arsitektur Fluttea & User

---

## Konteks & Masalah
Dalam pengembangan aplikasi Flutter skala menengah hingga besar, state management dan Dependency Injection (DI) yang modular sangat penting. Dua pendekatan dominan dalam ekosistem Riverpod adalah:
1. **Riverpod dengan Codegen (`riverpod_generator` + `build_runner`)**: Menghasilkan provider dan family secara otomatis menggunakan anotasi `@riverpod`.
2. **Riverpod Murni Tanpa Codegen (`flutter_riverpod` 3.5 native)**: Mendefinisikan class `Notifier` / `AsyncNotifier` dan `NotifierProvider` secara eksplisit dalam kode Dart standar.

Template proyek sebelumnya (seperti Nyx) mengalami masalah penurunan produktivitas developer karena:
* Eksekusi `build_runner` yang lambat pada mesin CI dan mesin developer lokal.
* Konflik file generated (`*.g.dart`) saat merge branch Git.
* Pengikatan ketat model/domain logic terhadap tool codegen eksternal.

## Keputusan
Kami memutuskan untuk menggunakan **`flutter_riverpod` versi 3.5 tanpa codegen** untuk seluruh state management dan Dependency Injection di Fluttea.
* Satu konsep state didefinisikan dalam satu file ringkas (class `Notifier` / `AsyncNotifier` dan satu baris deklarasi provider publik).
* Codegen di dalam proyek ini dibatasi secara ketat hanya untuk serialisasi data model (`freezed` dan `json_serializable`) serta interface platform channels native (`pigeon`).

## Konsekuensi

### Positif:
1. **Build Time Jauh Lebih Cepat:** Tidak memerlukan proses kompilasi code generator Riverpod pada siklus edit-debug.
2. **Bebas Konflik Merge Git:** Tidak ada file `*.g.dart` untuk provider yang harus di-track atau di-re-generate.
3. **Keterbacaan & Transparansi Kode:** Setiap dependency, lifecycle, dan tipe state terlihat jelas secara langsung di kode Dart tanpa magic annotation.
4. **Dart 3.14+ Compatibility:** Memanfaatkan fitur Dart modern seperti constructor `const new(...)`, pattern matching pada `AsyncValue`, dan sealed class secara murni.

### Negatif / Mitigasi:
* *Kekurangan:* Menulis definisi provider membutuhkan satu baris boilerplate (`final myProvider = NotifierProvider<MyNotifier, MyState>(MyNotifier.new);`).
* *Mitigasi:* Boilerplate sangat minimal (hanya 1 baris per notifier) dan telah diotomatisasi melalui template generator `tool/new_feature.sh`.

