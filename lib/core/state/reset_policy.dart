import 'dart:async';

import 'package:fluttea/core/state/lifecycle_provider.dart';
import 'package:fluttea/core/state/session_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

@immutable
sealed class ResetOn {
  const new();

  static const never = _ResetOnNever();
  static const logout = _ResetOnLogout();
  static const sessionExpired = _ResetOnSessionExpired();
  static const background = _ResetOnBackground();
  static const inactive = _ResetOnInactive();
  static const detached = _ResetOnDetached();
  static const lowMemory = _ResetOnLowMemory();

  static ResetOn backgroundFor(Duration duration) => _ResetOnBackgroundFor(duration);
  static ResetOn custom(bool Function() predicate) => _ResetOnCustom(predicate);
}

final class _ResetOnNever extends ResetOn {
  const new();
}

final class _ResetOnLogout extends ResetOn {
  const new();
}

final class _ResetOnSessionExpired extends ResetOn {
  const new();
}

final class _ResetOnBackground extends ResetOn {
  const new();
}

final class _ResetOnInactive extends ResetOn {
  const new();
}

final class _ResetOnDetached extends ResetOn {
  const new();
}

final class _ResetOnLowMemory extends ResetOn {
  const new();
}

final class _ResetOnBackgroundFor extends ResetOn {
  const new(this.duration);

  final Duration duration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _ResetOnBackgroundFor && other.duration == duration;

  @override
  int get hashCode => duration.hashCode;
}

final class _ResetOnCustom extends ResetOn {
  const new(this.predicate);

  final bool Function() predicate;
}

extension ResetOnX on Ref {
  /// Mengatur kebijakan kapan provider harus di-reset secara otomatis.
  void resetOn(Set<ResetOn> policies, {void Function()? onReset}) {
    if (policies.isEmpty || policies.contains(ResetOn.never)) {
      return;
    }

    void trigger() {
      if (onReset != null) {
        onReset();
      } else {
        invalidateSelf();
      }
    }

    final hasBackground = policies.any((p) => p is _ResetOnBackground);
    final hasInactive = policies.any((p) => p is _ResetOnInactive);
    final hasDetached = policies.any((p) => p is _ResetOnDetached);
    final hasLowMemory = policies.any((p) => p is _ResetOnLowMemory);
    final bgForPolicies = policies.whereType<_ResetOnBackgroundFor>().toList();

    if (hasBackground || hasInactive || hasDetached || hasLowMemory || bgForPolicies.isNotEmpty) {
      listen<AppLifecycleStateData>(appLifecycleProvider, (previous, next) {
        if (hasBackground && next.state == AppLifecycleState.paused) {
          trigger();
          return;
        }
        if (hasInactive && next.state == AppLifecycleState.inactive) {
          trigger();
          return;
        }
        if (hasDetached && next.state == AppLifecycleState.detached) {
          trigger();
          return;
        }
        if (hasLowMemory && next.isLowMemory) {
          trigger();
          return;
        }
        if (next.state == AppLifecycleState.resumed && bgForPolicies.isNotEmpty) {
          for (final policy in bgForPolicies) {
            if (next.backgroundDuration >= policy.duration) {
              trigger();
              return;
            }
          }
        }
      });
    }

    final hasLogout = policies.any((p) => p is _ResetOnLogout);
    final hasSessionExpired = policies.any((p) => p is _ResetOnSessionExpired);

    if (hasLogout || hasSessionExpired) {
      listen<SessionState>(sessionProvider, (previous, next) {
        if (hasLogout && previous is AuthenticatedSession && next is UnauthenticatedSession) {
          trigger();
          return;
        }
        if (hasSessionExpired && next is ExpiredSession) {
          trigger();
          return;
        }
      });
    }

    final customPolicies = policies.whereType<_ResetOnCustom>().toList();
    for (final custom in customPolicies) {
      if (custom.predicate()) {
        trigger();
        return;
      }
    }
  }

  /// Mempertahankan state provider sementara selama [duration] setelah semua listener dilepas.
  void cacheFor(Duration duration) {
    final link = keepAlive();
    final timer = Timer(duration, link.close);
    onDispose(timer.cancel);
  }
}
