import 'package:fluttea/core/state/lifecycle_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('AppLifecycleProvider', () {
    test('initializes with resumed or binding state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(appLifecycleProvider);
      expect(state.state, equals(AppLifecycleState.resumed));
      expect(state.backgroundDuration, equals(Duration.zero));
      expect(state.isLowMemory, isFalse);
    });

    test('updateState and notifyLowMemory update state values', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(appLifecycleProvider.notifier)
          .updateState(AppLifecycleState.paused, backgroundDuration: const Duration(seconds: 15));

      var state = container.read(appLifecycleProvider);
      expect(state.state, equals(AppLifecycleState.paused));
      expect(state.backgroundDuration, equals(const Duration(seconds: 15)));
      expect(state.isLowMemory, isFalse);

      container.read(appLifecycleProvider.notifier).notifyLowMemory();
      state = container.read(appLifecycleProvider);
      expect(state.isLowMemory, isTrue);
    });

    test('equality and copyWith work as expected', () {
      const data1 = AppLifecycleStateData(
        state: AppLifecycleState.resumed,
        backgroundDuration: Duration(seconds: 5),
      );
      const data2 = AppLifecycleStateData(
        state: AppLifecycleState.resumed,
        backgroundDuration: Duration(seconds: 5),
      );
      final data3 = data1.copyWith(isLowMemory: true);

      expect(data1, equals(data2));
      expect(data1.hashCode, equals(data2.hashCode));
      expect(data3.isLowMemory, isTrue);
      expect(data1.toString(), contains('AppLifecycleStateData('));
    });
  });
}
