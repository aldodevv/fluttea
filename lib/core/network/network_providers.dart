import 'package:fluttea/app/flavor.dart';
import 'package:fluttea/core/network/api_client.dart';
import 'package:fluttea/core/network/base_url/base_url_resolver.dart';
import 'package:fluttea/core/network/base_url/chain_base_url.dart';
import 'package:fluttea/core/network/base_url/flavor_base_url.dart';
import 'package:fluttea/core/network/base_url/override_base_url.dart';
import 'package:fluttea/core/network/debug/network_inspector.dart';
import 'package:fluttea/core/network/debug/request_logger.dart';
import 'package:fluttea/core/network/interceptors/app_interceptor.dart';
import 'package:fluttea/core/network/interceptors/headers_interceptor.dart';
import 'package:fluttea/core/network/interceptors/log_interceptor.dart';
import 'package:fluttea/core/network/interceptors/request_id_interceptor.dart';
import 'package:fluttea/core/network/network_config.dart';
import 'package:fluttea/core/network/profile/network_profile.dart';
import 'package:fluttea/core/storage/prefs/preferences_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final networkInspectorProvider = Provider<NetworkInspector>((ref) {
  return NetworkInspector();
});

final baseUrlResolverProvider = Provider<BaseUrlResolver>((ref) {
  // Ambil konfigurasi environment saat ini
  final prefs = PreferencesStorage();
  return ChainBaseUrlResolver(
    resolvers: [
      OverrideBaseUrlResolver(prefs),
      FlavorBaseUrlResolver(AppEnv.of(AppFlavor.dev).baseUrl),
    ],
  );
});

final networkProfileProvider = Provider<NetworkProfile>((ref) {
  // Default menggunakan MockServer profile untuk fleksibilitas testing
  return NetworkProfile.mockServer();
});

final networkConfigProvider = Provider<NetworkConfig>((ref) {
  final profile = ref.watch(networkProfileProvider);
  final resolver = ref.watch(baseUrlResolverProvider);
  final inspector = ref.watch(networkInspectorProvider);

  final defaultInterceptors = <AppInterceptor>[
    const RequestIdInterceptor(),
    const HeadersInterceptor(),
    LogInterceptor(
      logger: RequestLogger(level: profile.logLevel),
      inspector: inspector,
    ),
  ];

  return NetworkConfig.fromProfile(
    profile,
    resolver: resolver,
    interceptors: defaultInterceptors,
    inspector: inspector,
  );
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(networkConfigProvider);
  final client = ApiClient(config: config);
  ref.onDispose(client.rawDio.close);
  return client;
});
