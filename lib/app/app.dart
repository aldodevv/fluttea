import 'package:fluttea/app/providers.dart';
import 'package:fluttea/app/router/routes.dart';
import 'package:fluttea/core/devtools/widgets/devtools_floating_overlay.dart';
import 'package:fluttea/core/l10n/app_localizations.dart';
import 'package:fluttea/core/state/session_state_provider.dart';
import 'package:fluttea/core/theme/app_theme.dart';
import 'package:fluttea/features/settings/state/settings_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class App extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late final GoRouter _router = createRouter(ref: ref);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SessionState>(sessionProvider, (_, _) {
      _router.refresh();
    });

    final env = ref.watch(appEnvProvider);
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: env.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: _router,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        if (!env.devToolsEnabled) return child;
        return DevToolsFloatingOverlay(router: _router, child: child);
      },
    );
  }
}
