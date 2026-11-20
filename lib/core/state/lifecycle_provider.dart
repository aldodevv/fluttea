import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

@immutable
final class AppLifecycleStateData {
  const new({
    required this.state,
    this.backgroundDuration = Duration.zero,
    this.isLowMemory = false,
  });

  final AppLifecycleState state;
  final Duration backgroundDuration;
  final bool isLowMemory;

  AppLifecycleStateData copyWith({
    AppLifecycleState? state,
    Duration? backgroundDuration,
    bool? isLowMemory,
  }) {
    return AppLifecycleStateData(
      state: state ?? this.state,
      backgroundDuration: backgroundDuration ?? this.backgroundDuration,
      isLowMemory: isLowMemory ?? this.isLowMemory,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppLifecycleStateData &&
        other.state == state &&
        other.backgroundDuration == backgroundDuration &&
        other.isLowMemory == isLowMemory;
  }

  @override
  int get hashCode => Object.hash(state, backgroundDuration, isLowMemory);

  @override
  String toString() =>
      'AppLifecycleStateData(state: $state, backgroundDuration: $backgroundDuration, isLowMemory: $isLowMemory)';
}

class AppLifecycleNotifier extends Notifier<AppLifecycleStateData> {
  final Stopwatch _backgroundStopwatch = Stopwatch();
  AppLifecycleListener? _listener;

  @override
  AppLifecycleStateData build() {
    var initial = AppLifecycleState.resumed;
    try {
      initial = WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
      _listener = AppLifecycleListener(onStateChange: _onStateChange);
    } on Object catch (_) {
      // Fallback jika binding belum diinisialisasi (misal saat pure unit test).
    }

    ref.onDispose(() {
      _listener?.dispose();
      _backgroundStopwatch.stop();
    });

    return AppLifecycleStateData(state: initial);
  }

  void _onStateChange(AppLifecycleState nextState) {
    final prevState = state.state;

    if (nextState == AppLifecycleState.paused ||
        nextState == AppLifecycleState.hidden ||
        nextState == AppLifecycleState.inactive) {
      if (!_backgroundStopwatch.isRunning) {
        _backgroundStopwatch
          ..reset()
          ..start();
      }
      state = state.copyWith(state: nextState);
    } else if (nextState == AppLifecycleState.resumed) {
      var elapsed = Duration.zero;
      if (_backgroundStopwatch.isRunning) {
        _backgroundStopwatch.stop();
        elapsed = _backgroundStopwatch.elapsed;
      }
      state = state.copyWith(state: nextState, backgroundDuration: elapsed);
    } else {
      state = state.copyWith(state: nextState);
    }

    if (kDebugMode && prevState != nextState) {
      debugPrint('[Lifecycle] $prevState -> $nextState (bg duration: ${state.backgroundDuration})');
    }
  }

  /// Memperbarui state secara eksplisit (misal untuk pengujian simulasi lifecycle).
  void updateState(
    AppLifecycleState nextState, {
    Duration? backgroundDuration,
    bool isLowMemory = false,
  }) {
    state = state.copyWith(
      state: nextState,
      backgroundDuration: backgroundDuration,
      isLowMemory: isLowMemory,
    );
  }

  /// Memperbarui status low memory dari platform.
  void notifyLowMemory() {
    state = state.copyWith(isLowMemory: true);
  }
}

final appLifecycleProvider = NotifierProvider<AppLifecycleNotifier, AppLifecycleStateData>(
  AppLifecycleNotifier.new,
);
