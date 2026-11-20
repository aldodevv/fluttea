# 05 — State Management (Riverpod 3, tanpa codegen)

Keputusan: `flutter_riverpod` 3.5 dipakai untuk **state, DI, dan scope sekaligus**. Alasan: satu class + satu baris provider dalam satu file (bukan 3 file ala bloc), `autoDispose` bawaan untuk siklus hidup, `ref.invalidate` untuk reset, tes mudah via `ProviderContainer`/override. Tanpa `riverpod_generator`, tanpa `hooks_riverpod`. Verifikasi API lewat Context7 (`/rrousselgit/riverpod`) sebelum menulis; di Riverpod 3 `Ref` yang dipakai setelah dispose melempar `UnmountedRefException`, jadi cek `ref.mounted` setelah `await`.

```
core/state/
├─ lifecycle_provider.dart   # AppLifecycleListener → provider (state + waktu background monotonic)
├─ reset_policy.dart         # ResetOn + extension ref.resetOn(...)
├─ route_scope.dart          # provider yang hidup selama route (autoDispose + ProviderScope per route)
├─ async_view.dart           # widget AsyncValue → loading/empty/error/data seragam (core/widgets/states)
└─ result_ext.dart           # Result<T> → AsyncValue / throw Failure di AsyncNotifier
```

## Contoh (satu file per fitur)
```dart
class CartNotifier extends Notifier<Cart> {
  @override
  Cart build() {
    ref.resetOn({ResetOn.logout, ResetOn.backgroundFor(Duration(minutes: 5))});
    return const Cart();
  }
  void add(Item i) => state = state.add(i);
}
final cartProvider = NotifierProvider<CartNotifier, Cart>(CartNotifier.new);
```
Async: `AsyncNotifier` + repository `Result<T>`; UI `ref.watch(p).when(...)` atau `AsyncView`.

## Cakupan
| Kebutuhan | Cara |
|---|---|
| Global (hidup selama proses) | `NotifierProvider` biasa |
| Per halaman | `NotifierProvider.autoDispose` (hilang saat tak ada listener) atau `ProviderScope` per route |
| Lokal widget | `ValueNotifier`/`setState` hanya untuk state UI murni |
| Session | provider yang di-`invalidate` saat logout; `sessionProvider` dipakai `resetOn(logout)` |
| Parameter | `.family` |
| Pertahankan sementara | `ref.keepAlive()` + timer (`ref.cacheFor(Duration)` helper) |

## Reset policy (`ref.resetOn({...})`)
Implementasi mendengarkan `lifecycleProvider` / `sessionProvider` / `connectivity` dan memanggil `ref.invalidateSelf()` (atau `onReset` kustom).

| Trigger | Arti |
|---|---|
| `never` | default |
| `logout`, `sessionExpired` | ikut sesi |
| `background` | saat `paused` |
| `backgroundFor(Duration)` | background lebih lama dari durasi; diukur `Stopwatch` (monotonic), dicek saat `resumed`; tahan perubahan jam perangkat |
| `inactive` | `inactive` (app switcher, panggilan, panel notifikasi): untuk data sensitif |
| `detached` | engine lepas |
| `lowMemory` | `didHaveMemoryPressure` → buang cache non-kritis |
| `routeLeave` | via `autoDispose`/`ProviderScope` route |
| `manual` | `ref.invalidate(provider)` |
| `custom(test)` | predikat bebas |
Persist opsional hanya lewat `core/storage` (secure + terenkripsi untuk data sensitif); default tidak persist.

## Aturan
- Tidak ada state di `static`/global var. Semua lewat provider.
- Notifier tidak memegang `BuildContext`. Navigasi/dialog lewat provider event (`uiEventProvider`) yang didengar screen, atau `ref.listen`.
- State immutable (`freezed` bila punya ≥ 3 field atau union; record/`copyWith` kecil bila tidak).
- `ref.watch` di `build`, `ref.read` di callback, `ref.listen` untuk efek samping. Pakai `select` untuk rebuild sempit.
- `ref.mounted` dicek setelah `await` sebelum memakai `ref`.
- Repository, `ApiClient`, `SecurityProvider`, `RemoteConfigService` diekspos sebagai provider global di `app/providers.dart` (inilah DI; tidak ada get_it/injectable).
- Router: `go_router` dengan `refreshListenable` dari `sessionProvider`.
- Test: `ProviderContainer(overrides: [...])`; reset policy diuji dengan `lifecycleProvider` yang di-override dan jam palsu.

## Alternatif bila Riverpod ditolak
State buatan sendiri di SDK (`ChangeNotifier` + `ListenableBuilder` + `InheritedNotifier` + `AppLifecycleListener`), ±300 baris dipelihara sendiri, API `ResetOn` sama. Keputusan ada di `docs/research/00_REVIEW.md` bagian 5.
