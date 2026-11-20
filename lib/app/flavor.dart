import 'package:fluttea/core/constants/api/api_hosts.dart';

enum AppFlavor { dev, prod }

/// Satu-satunya tempat yang boleh membedakan perilaku per flavor.
final class AppEnv {
  const new({
    required this.flavor,
    required this.name,
    required this.baseUrl,
    required this.devToolsEnabled,
    required this.allowUrlOverride,
    required this.pinningEnabled,
  });

  factory of(AppFlavor flavor) => switch (flavor) {
    AppFlavor.dev => const AppEnv(
      flavor: AppFlavor.dev,
      name: 'Fluttea Dev',
      baseUrl: ApiHosts.dev,
      devToolsEnabled: true,
      allowUrlOverride: true,
      pinningEnabled: false,
    ),
    AppFlavor.prod => const AppEnv(
      flavor: AppFlavor.prod,
      name: 'Fluttea',
      baseUrl: ApiHosts.prod,
      devToolsEnabled: false,
      allowUrlOverride: false,
      pinningEnabled: true,
    ),
  };

  final AppFlavor flavor;
  final String name;
  final String baseUrl;
  final bool devToolsEnabled;
  final bool allowUrlOverride;
  final bool pinningEnabled;
}
