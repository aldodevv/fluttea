import 'package:fluttea/app/flavor.dart';
import 'package:fluttea/app/router/routes.dart';
import 'package:fluttea/core/state/session_state_provider.dart';

/// Memisahkan rute aplikasi menjadi kategori Public, Private, dan DevOnly.
abstract final class AuthGuard {
  /// Halaman publik yang dapat diakses tanpa autentikasi.
  static const Set<String> publicPaths = {SplashRoute.path, LoginRoute.path};

  static bool isPublic(String location) => publicPaths.contains(location);

  static bool isDevToolsPath(String location) => location.startsWith(DevToolsRoute.path);

  /// Mengevaluasi redirect berdasarkan status autentikasi dan environment flavor.
  static String? redirect({
    required String matchedLocation,
    required SessionState session,
    AppEnv? env,
  }) {
    if (isDevToolsPath(matchedLocation)) {
      if (env != null && !env.devToolsEnabled) {
        return session.isAuthenticated ? HomeRoute.path : LoginRoute.path;
      }
      return null;
    }

    if (session.isAuthenticated) {
      if (isPublic(matchedLocation)) {
        return HomeRoute.path;
      }
      return null;
    }

    // Default-deny (fail-closed): seluruh halaman non-public bersifat private.
    if (!isPublic(matchedLocation)) {
      return LoginRoute.path;
    }

    return null;
  }
}
