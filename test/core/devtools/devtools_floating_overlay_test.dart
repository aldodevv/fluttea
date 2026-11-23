import 'package:fluttea/app/app.dart';
import 'package:fluttea/app/flavor.dart';
import 'package:fluttea/app/providers.dart';
import 'package:fluttea/app/router/routes.dart';
import 'package:fluttea/core/constants/app/app_info.dart';
import 'package:fluttea/core/devtools/widgets/devtools_floating_overlay.dart';
import 'package:fluttea/core/state/session_state_provider.dart';
import 'package:fluttea/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class _AuthenticatedSessionNotifier extends SessionNotifier {
  @override
  SessionState build() => const SessionState.authenticated(userId: 'dev_user', token: 'dev_token');
}

void main() {
  group('DevToolsFloatingOverlay', () {
    testWidgets('shows floating pill on regular routes, hides on /devtools, and navigates on tap', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: Center(child: Text('HomeBody'))),
          ),
          GoRoute(
            path: AppRoutes.devTools,
            builder: (_, _) => const Scaffold(body: Center(child: Text('DevToolsBody'))),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
          builder: (context, child) => DevToolsFloatingOverlay(router: router, child: child!),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('HomeBody'), findsOneWidget);
      expect(find.text(AppInfo.devToolsBadge), findsOneWidget);

      // Draggable without errors and updates position
      final beforeDrag = tester.getTopLeft(find.text(AppInfo.devToolsBadge));
      await tester.drag(find.text(AppInfo.devToolsBadge), const Offset(-80, -80));
      await tester.pumpAndSettle();
      expect(find.text(AppInfo.devToolsBadge), findsOneWidget);
      final afterDrag = tester.getTopLeft(find.text(AppInfo.devToolsBadge));
      expect(afterDrag, isNot(equals(beforeDrag)));

      // Tapping opens DevTools and hides the floating pill on /devtools
      await tester.tap(find.text(AppInfo.devToolsBadge));
      await tester.pumpAndSettle();

      expect(find.text('DevToolsBody'), findsOneWidget);
      expect(find.text(AppInfo.devToolsBadge), findsNothing);

      // Closing DevTools restores the floating pill at its dragged position
      router.pop();
      await tester.pumpAndSettle();

      expect(find.text('HomeBody'), findsOneWidget);
      expect(find.text(AppInfo.devToolsBadge), findsOneWidget);
      expect(tester.getTopLeft(find.text(AppInfo.devToolsBadge)), equals(afterDrag));
    });

    testWidgets('AppBar back button pops devtools back to home without looping', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appEnvProvider.overrideWithValue(AppEnv.of(AppFlavor.dev)),
            sessionProvider.overrideWith(_AuthenticatedSessionNotifier.new),
          ],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Open devtools via floating button
      expect(find.text(AppInfo.devToolsBadge), findsOneWidget);
      await tester.tap(find.text(AppInfo.devToolsBadge));
      await tester.pumpAndSettle();

      expect(find.text('Fluttea DevTools'), findsOneWidget);
      expect(find.text(AppInfo.devToolsBadge), findsNothing);

      // Tap AppBar back button
      final backButton = find.byType(BackButton);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Successfully returned to home, DevTools is closed and floating badge is restored
      expect(find.text('Fluttea DevTools'), findsNothing);
      expect(find.text(AppInfo.devToolsBadge), findsOneWidget);
    });

    testWidgets('App hides floating DevTools in prod flavor', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appEnvProvider.overrideWithValue(AppEnv.of(AppFlavor.prod))],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppInfo.devToolsBadge), findsNothing);
    });
  });
}
