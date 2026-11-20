import 'package:fluttea/app/flavor.dart';
import 'package:fluttea/app/providers.dart';
import 'package:fluttea/app/router/routes.dart';
import 'package:fluttea/core/state/session_state_provider.dart';
import 'package:fluttea/core/widgets/loading/app_loader.dart';
import 'package:fluttea/features/auth/presentation/screens/login_screen.dart';
import 'package:fluttea/features/home/presentation/screens/home_screen.dart';
import 'package:fluttea/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class _AuthSessionNotifier extends SessionNotifier {
  @override
  SessionState build() =>
      const SessionState.authenticated(userId: 'u123', token: 'tok123', email: 'user@fluttea.dev');
}

void main() {
  final env = AppEnv.of(AppFlavor.dev);

  Widget createTestWidget({
    required GoRouter router,
    SessionNotifier Function()? sessionNotifierBuilder,
  }) {
    return ProviderScope(
      overrides: [
        appEnvProvider.overrideWithValue(env),
        if (sessionNotifierBuilder != null) sessionProvider.overrideWith(sessionNotifierBuilder),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('SplashScreen renders Fluttea branding and AppLoader', (tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
        GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
      ],
    );

    await tester.pumpWidget(createTestWidget(router: router));
    expect(find.text('Fluttea'), findsOneWidget);
    expect(find.text('Template Flutter Ringkas, Aman & Tangguh'), findsOneWidget);
    expect(find.byType(AppLoader), findsOneWidget);

    // After delay, navigates away
    await tester.pumpAndSettle();
  });

  testWidgets('SplashScreen navigates to login when unauthenticated', (tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
        GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
      ],
    );

    await tester.pumpWidget(createTestWidget(router: router));
    await tester.pumpAndSettle();

    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('SplashScreen navigates to home when authenticated', (tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
        GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      ],
    );

    await tester.pumpWidget(
      createTestWidget(router: router, sessionNotifierBuilder: _AuthSessionNotifier.new),
    );
    await tester.pumpAndSettle();

    expect(find.text('Halo, user@fluttea.dev!'), findsOneWidget);
  });
}
