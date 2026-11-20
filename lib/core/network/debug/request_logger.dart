import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluttea/core/constants/security/redacted_keys.dart';
import 'package:fluttea/core/logging/app_log.dart';

enum NetworkLogLevel { off, basic, headers, body }

class RequestLogger {
  const new({this.level = NetworkLogLevel.basic});

  final NetworkLogLevel level;

  void logRequest(RequestOptions options) {
    if (level == NetworkLogLevel.off) return;

    final id = options.extra['requestId'] ?? '-';
    final method = options.method.toUpperCase();
    final uri = options.uri;
    final path = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;

    var extra = '';
    if (level == NetworkLogLevel.body && options.data != null) {
      extra = ' body: ${formatBody(options.data)}';
    }

    AppLog.d('→ [$id] $method $path$extra', tag: 'Network');

    if (level == NetworkLogLevel.headers || level == NetworkLogLevel.body) {
      final sanitizedHeaders = sanitizeHeaders(options.headers);
      AppLog.d('  Headers: $sanitizedHeaders', tag: 'Network');
    }
  }

  void logResponse(Response<dynamic> response) {
    if (level == NetworkLogLevel.off) return;

    final id = response.requestOptions.extra['requestId'] ?? '-';
    final status = response.statusCode ?? 0;
    final duration = calculateDuration(response.requestOptions);
    final size = formatByteSize(response.data);

    var extra = '';
    if (level == NetworkLogLevel.body && response.data != null) {
      extra = ' body: ${formatBody(response.data)}';
    }

    AppLog.d('← [$id] $status OK ${duration}ms $size$extra', tag: 'Network');
  }

  void logError(DioException error) {
    if (level == NetworkLogLevel.off) return;

    final id = error.requestOptions.extra['requestId'] ?? '-';
    final method = error.requestOptions.method.toUpperCase();
    final path = error.requestOptions.uri.path;
    final status = error.response?.statusCode ?? 0;
    final duration = calculateDuration(error.requestOptions);
    final msg = error.message ?? error.error?.toString() ?? error.type.name;

    AppLog.w('✗ [$id] $method $path $status ${duration}ms $msg', tag: 'Network');
  }

  static int calculateDuration(RequestOptions options) {
    final start = options.extra['requestStart'] as int?;
    if (start == null) return 0;
    return DateTime.now().millisecondsSinceEpoch - start;
  }

  static Map<String, dynamic> sanitizeHeaders(Map<String, dynamic> headers) {
    return headers.map((key, value) {
      if (RedactedKeys.headers.contains(key.toLowerCase())) {
        return MapEntry(key, '***REDACTED***');
      }
      return MapEntry(key, value);
    });
  }

  static dynamic sanitizeBody(dynamic body) {
    if (body is Map) {
      return body.map((key, value) {
        final keyStr = key.toString().toLowerCase();
        if (RedactedKeys.bodyFields.contains(keyStr)) {
          return MapEntry(key, '***REDACTED***');
        }
        return MapEntry(key, sanitizeBody(value));
      });
    } else if (body is List) {
      return body.map(sanitizeBody).toList();
    }
    return body;
  }

  static String formatBody(dynamic body) {
    try {
      final sanitized = sanitizeBody(body);
      final raw = json.encode(sanitized);
      if (raw.length > 300) {
        return '${raw.substring(0, 300)}... (${raw.length} bytes)';
      }
      return raw;
    } on Object {
      return body.toString();
    }
  }

  static String formatByteSize(dynamic data) {
    if (data == null) return '0B';
    final len = data is String ? data.length : json.encode(data).length;
    if (len < 1024) return '${len}B';
    return '${(len / 1024).toStringAsFixed(1)}KB';
  }
}
