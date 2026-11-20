import 'package:fluttea/app/providers.dart';
import 'package:fluttea/app/router/guards/auth_guard.dart';
import 'package:fluttea/core/devtools/devtools_screen.dart';
import 'package:fluttea/core/devtools/gallery/component_gallery_screen.dart';
import 'package:fluttea/core/devtools/gallery/network_examples_screen.dart';
import 'package:fluttea/core/devtools/gallery/security_examples_screen.dart';
import 'package:fluttea/core/devtools/gallery/state_examples_screen.dart';
import 'package:fluttea/core/state/session_state_provider.dart';
import 'package:fluttea/features/auth/presentation/screens/login_screen.dart';
import 'package:fluttea/features/home/presentation/screens/home_screen.dart';
import 'package:fluttea/features/settings/presentation/screens/settings_screen.dart';
import 'package:fluttea/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

part 'routes.g.dart';

// =============================================================================
// PUBLIC ROUTES (Akses tanpa autentikasi)
// =============================================================================

@TypedGoRoute<SplashRoute>(path: SplashRoute.path)
class SplashRoute extends GoRouteData with $SplashRoute {
  const new();
  static const String path = '/splash';

  @override
  Widget build(BuildContext context, GoRouterState state) => const SplashScreen();
}

@TypedGoRoute<LoginRoute>(path: LoginRoute.path)
class LoginRoute extends GoRouteData with $LoginRoute {
  const new();
  static const String path = '/auth/login';

  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginScreen();
}

// =============================================================================
// PRIVATE ROUTES (Wajib terautentikasi via AuthGuard)
// =============================================================================

@TypedGoRoute<HomeRoute>(path: HomeRoute.path)
class HomeRoute extends GoRouteData with $HomeRoute {
  const new();
  static const String path = '/';

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

@TypedGoRoute<SettingsRoute>(path: SettingsRoute.path)
class SettingsRoute extends GoRouteData with $SettingsRoute {
  const new();
  static const String path = '/settings';

  @override
  Widget build(BuildContext context, GoRouterState state) => const SettingsScreen();
}

// =============================================================================
// DEV-ONLY ROUTES (Aktif hanya jika env.devToolsEnabled == true)
// =============================================================================

@TypedGoRoute<DevToolsRoute>(
  path: DevToolsRoute.path,
  routes: [
    TypedGoRoute<GalleryRoute>(path: 'gallery'),
    TypedGoRoute<StateExamplesRoute>(path: 'state-examples'),
    TypedGoRoute<NetworkExamplesRoute>(path: 'network-examples'),
    TypedGoRoute<SecurityExamplesRoute>(path: 'security-examples'),
  ],
)
class DevToolsRoute extends GoRouteData with $DevToolsRoute {
  const new();
  static const String path = '/devtools';

  @override
  Widget build(BuildContext context, GoRouterState state) => const DevToolsScreen();
}

class GalleryRoute extends GoRouteData with $GalleryRoute {
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ComponentGalleryScreen();
}

class StateExamplesRoute extends GoRouteData with $StateExamplesRoute {
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) => const StateExamplesScreen();
}

class NetworkExamplesRoute extends GoRouteData with $NetworkExamplesRoute {
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) => const NetworkExamplesScreen();
}

class SecurityExamplesRoute extends GoRouteData with $SecurityExamplesRoute {
  const new();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SecurityExamplesScreen();
}

/// Alias konstanta path untuk navigasi berbasis string bila diperlukan.
abstract final class AppRoutes {
  static const String splash = SplashRoute.path;
  static const String login = LoginRoute.path;
  static const String home = HomeRoute.path;
  static const String settings = SettingsRoute.path;
  static const String devTools = DevToolsRoute.path;
  static const String gallery = '${DevToolsRoute.path}/gallery';
  static const String stateExamples = '${DevToolsRoute.path}/state-examples';
  static const String networkExamples = '${DevToolsRoute.path}/network-examples';
  static const String securityExamples = '${DevToolsRoute.path}/security-examples';
}

GoRouter createRouter({
  String initialLocation = SplashRoute.path,
  WidgetRef? ref,
  SessionState Function()? sessionGetter,
  Listenable? refreshListenable,
}) => GoRouter(
  initialLocation: initialLocation,
  refreshListenable: refreshListenable,
  routes: $appRoutes,
  redirect: (context, state) {
    final session = sessionGetter != null ? sessionGetter() : ref?.read(sessionProvider);
    if (session == null) return null;

    final env = ref?.read(appEnvProvider);
    return AuthGuard.redirect(matchedLocation: state.matchedLocation, session: session, env: env);
  },
);
