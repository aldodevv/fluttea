import 'package:dio/dio.dart';
import 'package:fluttea/core/network/base_url/base_url_resolver.dart';

class FlavorBaseUrlResolver implements BaseUrlResolver {
  const new(this.defaultUrl);

  final String defaultUrl;

  @override
  Future<Uri> resolve({RequestOptions? options}) async {
    return Uri.parse(defaultUrl);
  }
}
