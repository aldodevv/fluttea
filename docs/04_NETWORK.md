# 04 — Network: Dio sebagai Wrapper "Lego"

Tujuan: Dio **independen** (tidak tahu flavor, UI, atau Firebase), dirakit dari modul kecil yang bisa dipasang/dilepas. Bukan static singleton; instance dibuat oleh `NetworkBuilder` dan didaftarkan sebagai provider global di `app/providers.dart`.

```
core/network/
├─ api_client.dart                # ApiClient: get/post/put/delete/upload/download → Result<T>
├─ network_builder.dart           # merakit Dio dari NetworkConfig + daftar modul
├─ network_config.dart            # timeout, headers default, retry, proxy, adapter, daftar modul
├─ base_url/
│  ├─ base_url_resolver.dart      # interface: Future<Uri> resolve()
│  ├─ flavor_base_url.dart        # default dari AppFlavor
│  ├─ override_base_url.dart      # nilai dari DevTools (disimpan di prefs, hanya non-prod bila diizinkan)
│  ├─ remote_config_base_url.dart # opsional
│  └─ chain_base_url.dart         # urutan: override → remote → flavor
├─ adapter/
│  ├─ adapter_factory.dart        # IOHttpClientAdapter / Http2Adapter / Native (opsional)
│  ├─ proxy_config.dart           # none | system | manual(host:port) | pac
│  └─ http_client_factory.dart    # SecurityContext, timeout koneksi, idle timeout
├─ pinning/                       # lihat research/pinning.md (pre-send, bukan post-response)
├─ profile/
│  ├─ network_profile.dart        # bundel konfigurasi siap pakai (lihat "Adaptif")
│  └─ response_schema.dart        # EnvelopeSpec + preset
├─ interceptors/                  # satu file = satu interceptor, semua implement AppInterceptor
│  ├─ request_id_interceptor.dart
│  ├─ headers_interceptor.dart        # device id, app version, locale
│  ├─ auth_token_interceptor.dart     # tempel token
│  ├─ refresh_token_interceptor.dart  # 401 → refresh sekali (single-flight) → ulang request
│  ├─ encrypt_request_interceptor.dart
│  ├─ decrypt_response_interceptor.dart
│  ├─ signature_interceptor.dart      # HMAC/ signature request (opsional)
│  ├─ time_sync_interceptor.dart
│  ├─ retry_interceptor.dart          # backoff + jitter, hanya idempotent
│  ├─ cache_interceptor.dart          # opsional, memori/disk
│  ├─ maintenance_interceptor.dart
│  ├─ connectivity_interceptor.dart   # gagal cepat bila offline
│  ├─ cancel_interceptor.dart
│  └─ log_interceptor.dart            # memakai AppLog
├─ handlers/
│  ├─ response/
│  │  ├─ response_handler.dart        # interface: Result<T>? handle(Response)
│  │  ├─ status_code_handler.dart
│  │  ├─ envelope_handler.dart        # format {code,message,data}; satu varian per backend
│  │  ├─ plain_json_handler.dart
│  │  └─ response_pipeline.dart       # urut handler, handler pertama yang mengklaim menang
│  ├─ error/
│  │  ├─ error_handler.dart           # DioException → Failure
│  │  ├─ failure_mapper.dart          # type/status/code backend → ErrorCodes (const)
│  │  └─ failure_messages.dart        # ErrorCodes → kunci l10n
│  └─ session/
│     ├─ session_workflow.dart        # interface: onUnauthorized, onExpired, onForceLogout
│     ├─ refresh_session_workflow.dart    # skema A: refresh token
│     ├─ reauth_session_workflow.dart     # skema B: login ulang diam-diam / PIN / biometrik
│     └─ force_logout_workflow.dart       # skema C: langsung logout
└─ debug/
   ├─ request_logger.dart         # format log ringkas (lihat di bawah)
   └─ network_inspector.dart      # buffer N request terakhir untuk DevTools
```

## Prinsip lego
- `AppInterceptor` = `Interceptor` + `String name` + `int order` + `bool enabled`. `NetworkBuilder` mengurutkan dengan `order` (konstanta di `constants/api/interceptor_order.dart`), sehingga urutan eksplisit dan terdokumentasi, bukan implisit di list.
- Modul diaktifkan per project di `network_config.dart`:
  ```dart
  NetworkConfig(
    interceptors: [RequestId(), Headers(...), AuthToken(...), Retry(), Log()],
    responsePipeline: [StatusCodeHandler(), EnvelopeHandler()],
    session: RefreshSessionWorkflow(...),
    pinning: PinningStrategy.spki(pins),
  )
  ```
- Interceptor tidak boleh mengambil `BuildContext`/navigator. Aksi UI (maintenance, force logout) lewat `Stream`/`ValueNotifier` event yang didengar `app/`.
- `validateStatus` default Dio dipertahankan (2xx). Status lain diolah `ResponseHandler`/`ErrorHandler` secara eksplisit.
- `ApiClient` tidak pernah melempar: semua jalur menghasilkan `Result<T>` (`Ok<T>` / `Err<Failure>`). `CancelToken` dikembalikan ke pemanggil untuk membatalkan saat notifier di-dispose (`ref.onDispose`).

## Adaptif terhadap backend (belum diputuskan)
Backend tiap project berbeda dan infra belum disetujui, jadi semua keputusan transport adalah **opsi konfigurasi**, bukan kode fitur:

| Opsi | Pilihan yang disiapkan |
|---|---|
| Skema respons | `EnvelopeSpec(successKey, successValues, codeKey, messageKey, dataKey, pageKeys)` (envelope `{code,message,data}` dengan nama kunci bebas) · `HttpNative` (2xx = body, error = status) · `ProblemJson` (RFC 9457) · `JsonApi` · `GraphQl` (`errors[]`) · `Custom(ResponseHandler)` |
| Auth | Bearer · header kustom · cookie · API key · HMAC signature; tanpa auth |
| Sesi | `RefreshSessionWorkflow` · `ReauthSessionWorkflow` · `ForceLogoutWorkflow` · `ServerSessionWorkflow` (cookie) |
| Enkripsi payload | off · suite dari `CipherRegistry` (AES-GCM, ChaCha20) · envelope terenkripsi + `kid` |
| Signature request | off · HMAC-SHA256 (timestamp + nonce + body hash) |
| Pinning | lihat `research/pinning.md` |
| Pagination | page/size · offset/limit · cursor |
| Retry | off · idempoten saja · semua dengan backoff + jitter |
| Transport | `IOHttpClientAdapter` (default) · HTTP/2 · adapter native (`cupertino_http`/`cronet_http`) |

`NetworkProfile` memberi nama bundel, mis. `NetworkProfile.plainRest()`, `.enveloped()`, `.encryptedEnveloped()`. Project memilih satu di `app/providers.dart`; mengganti backend berarti mengganti profile, bukan mengubah repository. Setiap preset punya test yang memakai server tiruan lokal.

## Base URL (semua skema, satu interface)
| Skema | Sumber | Dipakai |
|---|---|---|
| Flavor default | `AppEnv.baseUrl` (dev/prod) di-compile | selalu ada sebagai fallback |
| DevTools override | prefs (`StorageKeys.baseUrlOverride`) | dev; prod hanya bila `AppEnv.allowUrlOverride` dan terlindungi PIN, default **off** |
| Remote config | `RcKeys.baseUrl` | opsional |
| Dinamis per request | `extra['baseUrl']` | multi-service |
Perubahan URL: `BaseUrlResolver` dibaca per request (bukan saat build Dio), jadi ganti URL dari DevTools berlaku langsung tanpa restart. URL wajib `https` di prod; validasi di resolver.

## Proxy & adapter
`ProxyConfig`: none, system, manual, dan "deteksi proxy" (dipakai sebagai sinyal security, lihat 06). Dev boleh proxy untuk Charles/Proxyman; prod: abaikan proxy manual dan tolak bila terdeteksi bila kebijakan project meminta. Adapter: `IOHttpClientAdapter` default; HTTP/2 (`dio_http2_adapter`) opsional; verifikasi API adapter di Dio terbaru via Context7.

## Logger (mudah dibaca manusia)
Satu baris ringkas per request, detail bisa dibuka:
```
→ [a1b2] POST /v1/auth/login            body: 142B (encrypted)
← [a1b2] 200 OK  184ms  1.2KB  code=SUCCESS
✗ [c3d4] GET  /v1/profile  401  93ms  Failure(unauthorized) → refresh → retry ok
```
- Level: `off | basic | headers | body`. Default dev `basic`, prod `off`.
- **Redaksi otomatis**: `Authorization`, `Cookie`, field `password/pin/otp/token/secret`, nomor kartu. Daftar field di `constants/security/redacted_keys.dart`.
- `NetworkInspector` menyimpan 100 request terakhir (ring buffer) → tab Network di DevTools (copy cURL, replay, filter status). Hanya aktif non-prod.

## Error terstruktur
`Failure(code: ErrorCodes.x, message: l10nKey, status?, backendCode?, cause?)` — sealed family: `NetworkFailure`, `TimeoutFailure`, `UnauthorizedFailure`, `ServerFailure`, `ParseFailure`, `PinningFailure`, `TamperedFailure`, `CancelledFailure`, `UnknownFailure`. Mapping DioExceptionType/status/backend code → Failure hanya di `failure_mapper.dart`. UI hanya membaca `failure.code`/`messageKey`.

## Pengujian
- Interceptor dites tunggal dengan `Dio` + adapter palsu (mocktail).
- Pipeline dites: tiap handler satu case.
- Test integrasi: `NetworkBuilder` dengan konfigurasi minimal dan maksimal.
