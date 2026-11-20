import 'package:fluttea/core/state/session_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionStateProvider', () {
    test('starts with unauthenticated state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final session = container.read(sessionProvider);
      expect(session.isUnauthenticated, isTrue);
      expect(session.isAuthenticated, isFalse);
      expect(session.isExpired, isFalse);
    });

    test('login transitions to authenticated session', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(sessionProvider.notifier)
          .login(userId: 'user_123', token: 'token_abc', email: 'user@fluttea.example');

      final session = container.read(sessionProvider);
      expect(session.isAuthenticated, isTrue);
      expect((session as AuthenticatedSession).userId, equals('user_123'));
      expect(session.token, equals('token_abc'));
      expect(session.email, equals('user@fluttea.example'));
    });

    test('logout transitions back to unauthenticated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(sessionProvider.notifier)..login(userId: 'u1', token: 't1');
      expect(container.read(sessionProvider).isAuthenticated, isTrue);

      notifier.logout();
      expect(container.read(sessionProvider).isUnauthenticated, isTrue);
    });

    test('expire transitions to expired state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(sessionProvider.notifier).expire();

      final session = container.read(sessionProvider);
      expect(session.isExpired, isTrue);
      expect(session.isAuthenticated, isFalse);
    });

    test('equality and toString', () {
      const u1 = UnauthenticatedSession();
      const u2 = UnauthenticatedSession();
      expect(u1, equals(u2));
      expect(u1.toString(), contains('UnauthenticatedSession'));

      const a1 = AuthenticatedSession(userId: 'u1', token: 't1');
      const a2 = AuthenticatedSession(userId: 'u1', token: 't1');
      const a3 = AuthenticatedSession(userId: 'u2', token: 't1');
      expect(a1, equals(a2));
      expect(a1, isNot(equals(a3)));
      expect(a1.toString(), contains('AuthenticatedSession'));

      const e1 = ExpiredSession();
      const e2 = ExpiredSession();
      expect(e1, equals(e2));
      expect(e1.toString(), contains('ExpiredSession'));
    });
  });
}
