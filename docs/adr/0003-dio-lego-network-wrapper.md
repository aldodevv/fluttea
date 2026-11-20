# ADR 0003: Arsitektur Modular Dio Lego Network Wrapper

* **Status:** Diterima (Accepted)
* **Tanggal:** 2026-11-15
* **Pengambil Keputusan:** Tim Arsitektur Fluttea & User

---

## Konteks & Masalah
Dalam pengembangan mobile app enterprise, backend API sering kali:
* Memiliki skema response yang berbeda-beda (Envelope standar `{code, data, message}`, plain JSON, error berformat RFC 7807 Problem Details).
* Berubah spesifikasi di tengah proses development.
* Membutuhkan mekanisme debugging proxy yang aman di lingkungan staging/dev.
* Membutuhkan pipeline transformasi exception ke `Result<T>` yang seragam agar layer UI tidak pernah mengalami unhandled exception crash.

Membuat instance Dio secara ad-hoc di tiap repository atau mengikat aplikasi ke satu format respon yang kaku menyebabkan refactoring besar ketika terjadi pergantian API backend.

## Keputusan
Kami merancang `ApiClient` Fluttea dengan konsep **"Dio Lego"** yang modular dan terisolasi:
1. **`NetworkConfig` & `NetworkProfile`:** Mengelompokkan konfigurasi timeout, headers, retry policy, error mapping, dan interceptors dalam preset siap pakai (`mockServer`, `production`, `custom`).
2. **`BaseUrlResolver` Chain:** Menyelesaikan Base URL melalui rangkaian hierarkis (`OverrideBaseUrlResolver` dari DevTools $\rightarrow$ `FlavorBaseUrlResolver` dari flavor aktif).
3. **Response Pipeline Separation:** Pemisahan antara parsing payload dan verifikasi envelope (`EnvelopeResponsePipeline`, `PlainJsonResponsePipeline`), memungkinkan adaptasi format respon tanpa mengubah kode repository.
4. **7 Interceptor Independen:**
   * `RequestIdInterceptor` (Tracing UUID v4)
   * `HeadersInterceptor` (User-Agent, Accept, Platform info)
   * `TimeSyncInterceptor` (Deteksi clock drift terhadap server)
   * `AuthTokenInterceptor` (Bearer token injection & auto-refresh)
   * `SignatureInterceptor` (Anti-replay HMAC request signature)
   * `LogInterceptor` (Masking PII otomatis ke Talker sink)
   * `RetryInterceptor` (Exponential backoff dengan jitter)
5. **Clean Result Pattern:** Seluruh API method (`get`, `post`, `put`, `delete`, `patch`) mengembalikan `Future<Result<T>>` (`Ok(value)` atau `Err(failure)`). Exception tidak pernah bocor ke UI.

## Konsekuensi

### Positif:
1. **Agilitas Tinggi:** Pergantian skema response backend (misal dari envelope custom ke standar REST plain JSON) hanya memerlukan penggantian 1 baris konfigurasi `ResponsePipeline`.
2. **Observabilitas Penuh:** Setiap request tercatat di `NetworkInspector` in-memory ring buffer yang dapat diinspeksi langsung pada tab Network di DevTools Hub.
3. **Zero Crash pada UI:** Presentasi UI dijamin aman karena UI hanya mengonsumsi model domain melalui sealed class `Result<T>` atau `AsyncValue<T>`.

### Negatif:
* Memerlukan abstraksi mapper (`ErrorMapper`, `ResponsePipeline`) pada setup awal, namun telah disediakan implementasi default yang siap pakai.

