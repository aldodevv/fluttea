import 'package:dio/dio.dart';
import 'package:fluttea/core/network/base_url/base_url_resolver.dart';

class RemoteConfigBaseUrlResolver implements BaseUrlResolver {
  const new(this.fetchUrl, {this.enforceHttps = false});

  final Future<String?> Function() fetchUrl;
  final bool enforceHttps;

  @override
  Future<Uri> resolve({RequestOptions? options}) async {
    final raw = await fetchUrl();
    if (raw == null || raw.trim().isEmpty) {
      throw const FormatException('Remote config base URL is empty.');
    }

    final uri = Uri.parse(raw.trim());
    if (enforceHttps && uri.scheme != 'https') {
      throw const FormatException('Remote config URL must use HTTPS.');
    }

    return uri;
  }
}
