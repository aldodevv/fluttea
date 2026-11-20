abstract final class UrlBuilder {
  static Uri build({required String baseUrl, String? path, Map<String, dynamic>? queryParameters}) {
    final baseUri = Uri.parse(baseUrl);
    var combinedPath = baseUri.path;

    if (path != null && path.isNotEmpty) {
      final normalizedBase = combinedPath.endsWith('/')
          ? combinedPath.substring(0, combinedPath.length - 1)
          : combinedPath;
      final normalizedPath = path.startsWith('/') ? path : '/$path';
      combinedPath = '$normalizedBase$normalizedPath';
    }

    final queryMap = <String, String>{};
    if (baseUri.queryParameters.isNotEmpty) {
      queryMap.addAll(baseUri.queryParameters);
    }
    if (queryParameters != null) {
      for (final entry in queryParameters.entries) {
        if (entry.value != null) {
          queryMap[entry.key] = entry.value.toString();
        }
      }
    }

    return baseUri.replace(
      path: combinedPath.isEmpty ? '/' : combinedPath,
      queryParameters: queryMap.isEmpty ? null : queryMap,
    );
  }
}
