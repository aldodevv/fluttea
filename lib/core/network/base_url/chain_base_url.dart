import 'package:dio/dio.dart';
import 'package:fluttea/core/network/base_url/base_url_resolver.dart';

class ChainBaseUrlResolver implements BaseUrlResolver {
  const new({required this.resolvers, this.enforceHttps = false});

  final List<BaseUrlResolver> resolvers;
  final bool enforceHttps;

  @override
  Future<Uri> resolve({RequestOptions? options}) async {
    // 1. Cek dynamic per-request extra
    final extraUrl = options?.extra['baseUrl'];
    if (extraUrl is String && extraUrl.trim().isNotEmpty) {
      final uri = Uri.parse(extraUrl.trim());
      if (enforceHttps && uri.scheme != 'https') {
        throw const FormatException('Dynamic base URL must use HTTPS.');
      }
      return uri;
    }

    // 2. Evaluasi rantai resolver berurutan
    for (final resolver in resolvers) {
      try {
        final uri = await resolver.resolve(options: options);
        if (enforceHttps && uri.scheme != 'https') {
          continue;
        }
        return uri;
      } on Object {
        // Lanjut ke resolver berikutnya dalam rantai
        continue;
      }
    }

    throw const FormatException('Could not resolve base URL from any provider in chain.');
  }
}
