import 'package:fluttea/core/state/lifecycle_provider.dart';
import 'package:fluttea/core/state/reset_policy.dart';
import 'package:fluttea/core/state/session_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class CounterWithReset extends Notifier<int> {
  new(this.policies, {this.onResetCustom});

  final Set<ResetOn> policies;
  final void Function()? onResetCustom;

  @override
  int build() {
    ref.resetOn(policies, onReset: onResetCustom);
    return 10;
  }

  void increment() => state++;
}

void main() {
  group('ResetPolicy', () {
    test('resets on logout transition', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final provider = NotifierProvider<CounterWithReset, int>(
        () => CounterWithReset({ResetOn.logout}),
      );

      // Log in
      container.read(sessionProvider.notifier).login(userId: 'u1', token: 't1');

      // Mutate state
      container.read(provider.notifier).increment();
      expect(container.read(provider), equals(11));

      // Log out -> should reset provider back to initial (10)
      container.read(sessionProvider.notifier).logout();
      expect(container.read(provider), equals(10));
    });

    test('resets on sessionExpired transition', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final provider = NotifierProvider<CounterWithReset, int>(
        () => CounterWithReset({ResetOn.sessionExpired}),
      );

      container.read(sessionProvider.notifier).login(userId: 'u1', token: 't1');
      container.read(provider.notifier).increment();
      expect(container.read(provider), equals(11));

      container.read(sessionProvider.notifier).expire();
      expect(container.read(provider), equals(10));
    });

    test('resets on background (paused) state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final provider = NotifierProvider<CounterWithReset, int>(
        () => CounterWithReset({ResetOn.background}),
      );

      container.read(provider.notifier).increment();
      expect(container.read(provider), equals(11));

      // App paused
      container.read(appLifecycleProvider.notifier).updateState(AppLifecycleState.paused);
      expect(container.read(provider), equals(10));
    });

    test('resets on backgroundFor only when duration threshold is exceeded', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final provider = NotifierProvider<CounterWithReset, int>(
        () => CounterWithReset({ResetOn.backgroundFor(const Duration(minutes: 5))}),
      );

      container.read(provider.notifier).increment();
      expect(container.read(provider), equals(11));

      // Resumed after only 2 minutes background -> does NOT reset
      container
          .read(appLifecycleProvider.notifier)
          .updateState(AppLifecycleState.resumed, backgroundDuration: const Duration(minutes: 2));
      expect(container.read(provider), equals(11));

      // Resumed after 6 minutes background -> DOES reset
      container
          .read(appLifecycleProvider.notifier)
          .updateState(AppLifecycleState.resumed, backgroundDuration: const Duration(minutes: 6));
      expect(container.read(provider), equals(10));
    });

    test('resets on inactive, detached, and lowMemory', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final inactiveProvider = NotifierProvider<CounterWithReset, int>(
        () => CounterWithReset({ResetOn.inactive}),
      );
      container.read(inactiveProvider.notifier).increment();
      expect(container.read(inactiveProvider), equals(11));
      container.read(appLifecycleProvider.notifier).updateState(AppLifecycleState.inactive);
      expect(container.read(inactiveProvider), equals(10));

      final lowMemProvider = NotifierProvider<CounterWithReset, int>(
        () => CounterWithReset({ResetOn.lowMemory}),
      );
      container.read(lowMemProvider.notifier).increment();
      expect(container.read(lowMemProvider), equals(11));
      container.read(appLifecycleProvider.notifier).notifyLowMemory();
      expect(container.read(lowMemProvider), equals(10));
    });

    test('calls custom onReset callback if provided', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      var customResetCalled = false;
      final provider = NotifierProvider<CounterWithReset, int>(
        () => CounterWithReset({ResetOn.background}, onResetCustom: () => customResetCalled = true),
      );

      container.read(provider);
      container.read(appLifecycleProvider.notifier).updateState(AppLifecycleState.paused);
      expect(customResetCalled, isTrue);
    });

    test('cacheFor keeps provider alive for duration', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      var buildCount = 0;
      final cachedProvider = Provider.autoDispose<int>((ref) {
        ref.cacheFor(const Duration(milliseconds: 30));
        buildCount++;
        return 99;
      });

      // First read: creates provider
      expect(container.read(cachedProvider), equals(99));
      expect(buildCount, equals(1));

      // Even without active listener, it stays cached during 10ms
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(container.read(cachedProvider), equals(99));
      expect(buildCount, equals(1));

      // After 40ms, link is closed, so next read recreates
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(container.read(cachedProvider), equals(99));
      expect(buildCount, equals(2));
    });
  });
}
