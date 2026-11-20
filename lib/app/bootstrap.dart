import 'package:fluttea/app/app.dart';
import 'package:fluttea/app/flavor.dart';
import 'package:fluttea/app/providers.dart';
import 'package:fluttea/core/logging/app_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:talker/talker.dart';

Future<void> bootstrap(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  final env = AppEnv.of(flavor);

  AppLog.init(
    enabled: env.devToolsEnabled || kDebugMode,
    minLevel: env.flavor == AppFlavor.prod ? LogLevel.error : LogLevel.debug,
  );

  FlutterError.onError = (details) {
    AppLog.handle(details.exception, details.stack, details.summary.name);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLog.handle(error, stack, 'UncaughtPlatformError');
    return true;
  };

  runApp(ProviderScope(overrides: [appEnvProvider.overrideWithValue(env)], child: const App()));
}
