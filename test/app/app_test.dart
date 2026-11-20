import 'package:fluttea/app/app.dart';
import 'package:fluttea/app/flavor.dart';
import 'package:fluttea/app/providers.dart';
import 'package:fluttea/core/state/session_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _AuthenticatedSessionNotifier extends SessionNotifier {
  @override
  SessionState build() => const SessionState.authenticated(userId: 'dev_user', token: 'dev_token');
}

void main() {
  for (final flavor in AppFlavor.values) {
    testWidgets('home shows ${flavor.name} env name and base url when authenticated', (
      tester,
    ) async {
      final env = AppEnv.of(flavor);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appEnvProvider.overrideWithValue(env),
            sessionProvider.overrideWith(_AuthenticatedSessionNotifier.new),
          ],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(env.name), findsWidgets);
      expect(find.text(env.baseUrl), findsOneWidget);
    });
  }

  testWidgets('app navigates to login when unauthenticated', (tester) async {
    final env = AppEnv.of(AppFlavor.dev);
    await tester.pumpWidget(
      ProviderScope(overrides: [appEnvProvider.overrideWithValue(env)], child: const App()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Masuk untuk melanjutkan ke ${env.name}'), findsOneWidget);
  });

  test('prod env enforces pinning and disables devtools and url override', () {
    final env = AppEnv.of(AppFlavor.prod);
    expect(env.pinningEnabled, isTrue);
    expect(env.devToolsEnabled, isFalse);
    expect(env.allowUrlOverride, isFalse);
  });
}
