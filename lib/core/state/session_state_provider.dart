import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
sealed class SessionState {
  const new();

  const factory unauthenticated() = UnauthenticatedSession;
  const factory authenticated({required String userId, required String token, String? email}) =
      AuthenticatedSession;
  const factory expired() = ExpiredSession;

  bool get isAuthenticated => this is AuthenticatedSession;
  bool get isUnauthenticated => this is UnauthenticatedSession;
  bool get isExpired => this is ExpiredSession;
}

final class UnauthenticatedSession extends SessionState {
  const new();

  @override
  String toString() => 'UnauthenticatedSession()';

  @override
  bool operator ==(Object other) => other is UnauthenticatedSession;

  @override
  int get hashCode => runtimeType.hashCode;
}

final class AuthenticatedSession extends SessionState {
  const new({required this.userId, required this.token, this.email});

  final String userId;
  final String token;
  final String? email;

  @override
  String toString() => 'AuthenticatedSession(userId: $userId, email: $email)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthenticatedSession &&
        other.userId == userId &&
        other.token == token &&
        other.email == email;
  }

  @override
  int get hashCode => Object.hash(userId, token, email);
}

final class ExpiredSession extends SessionState {
  const new();

  @override
  String toString() => 'ExpiredSession()';

  @override
  bool operator ==(Object other) => other is ExpiredSession;

  @override
  int get hashCode => runtimeType.hashCode;
}

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() {
    return const SessionState.unauthenticated();
  }

  void login({required String userId, required String token, String? email}) {
    state = SessionState.authenticated(userId: userId, token: token, email: email);
  }

  void logout() {
    state = const SessionState.unauthenticated();
  }

  void expire() {
    state = const SessionState.expired();
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);
