import 'package:fluttea/app/flavor.dart';
import 'package:fluttea/app/router/guards/auth_guard.dart';
import 'package:fluttea/app/router/routes.dart';
import 'package:fluttea/core/state/session_state_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final devEnv = AppEnv.of(AppFlavor.dev);
  final prodEnv = AppEnv.of(AppFlavor.prod);
  const unauth = SessionState.unauthenticated();
  const auth = SessionState.authenticated(userId: 'u1', token: 't1');

  group('AuthGuard public vs private routes', () {
    test('unauthenticated user can access public routes', () {
      expect(
        AuthGuard.redirect(matchedLocation: SplashRoute.path, session: unauth, env: devEnv),
        isNull,
      );
      expect(
        AuthGuard.redirect(matchedLocation: LoginRoute.path, session: unauth, env: devEnv),
        isNull,
      );
    });

    test('unauthenticated user is redirected from private routes to login', () {
      expect(
        AuthGuard.redirect(matchedLocation: HomeRoute.path, session: unauth, env: devEnv),
        LoginRoute.path,
      );
      expect(
        AuthGuard.redirect(matchedLocation: SettingsRoute.path, session: unauth, env: devEnv),
        LoginRoute.path,
      );
    });

    test('authenticated user is redirected away from public auth/splash to home', () {
      expect(
        AuthGuard.redirect(matchedLocation: SplashRoute.path, session: auth, env: devEnv),
        HomeRoute.path,
      );
      expect(
        AuthGuard.redirect(matchedLocation: LoginRoute.path, session: auth, env: devEnv),
        HomeRoute.path,
      );
    });

    test('authenticated user can access private routes', () {
      expect(
        AuthGuard.redirect(matchedLocation: HomeRoute.path, session: auth, env: devEnv),
        isNull,
      );
      expect(
        AuthGuard.redirect(matchedLocation: SettingsRoute.path, session: auth, env: devEnv),
        isNull,
      );
    });

    test('devtools routes are allowed in dev and blocked in prod', () {
      expect(
        AuthGuard.redirect(matchedLocation: AppRoutes.gallery, session: unauth, env: devEnv),
        isNull,
      );
      expect(
        AuthGuard.redirect(matchedLocation: AppRoutes.gallery, session: unauth, env: prodEnv),
        LoginRoute.path,
      );
      expect(
        AuthGuard.redirect(matchedLocation: AppRoutes.gallery, session: auth, env: prodEnv),
        HomeRoute.path,
      );
    });
  });
}
