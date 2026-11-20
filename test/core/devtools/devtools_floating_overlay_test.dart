import 'package:fluttea/app/app.dart';
import 'package:fluttea/app/flavor.dart';
import 'package:fluttea/app/providers.dart';
import 'package:fluttea/app/router/routes.dart';
import 'package:fluttea/core/constants/app/app_info.dart';
import 'package:fluttea/core/devtools/widgets/devtools_floating_overlay.dart';
import 'package:fluttea/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

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

      // Draggable without errors
      await tester.drag(find.text(AppInfo.devToolsBadge), const Offset(-80, -80));
      await tester.pumpAndSettle();
      expect(find.text(AppInfo.devToolsBadge), findsOneWidget);

      // Tapping opens DevTools and hides the floating pill on /devtools
      await tester.tap(find.text(AppInfo.devToolsBadge));
      await tester.pumpAndSettle();

      expect(find.text('DevToolsBody'), findsOneWidget);
      expect(find.text(AppInfo.devToolsBadge), findsNothing);
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
