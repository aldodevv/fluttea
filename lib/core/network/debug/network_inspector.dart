import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluttea/core/network/debug/request_logger.dart';

class NetworkTransaction {
  const new({
    required this.id,
    required this.method,
    required this.url,
    required this.durationMs,
    required this.timestamp,
    this.statusCode,
    this.requestHeaders = const {},
    this.requestBody,
    this.responseBody,
    this.error,
  });

  final String id;
  final String method;
  final String url;
  final int durationMs;
  final DateTime timestamp;
  final int? statusCode;
  final Map<String, dynamic> requestHeaders;
  final dynamic requestBody;
  final dynamic responseBody;
  final String? error;

  bool get isSuccess => statusCode != null && statusCode! >= 200 && statusCode! < 300;

  String toCurl() {
    final buffer = StringBuffer('curl -X $method "$url"');
    for (final entry in requestHeaders.entries) {
      buffer.write(' -H "${entry.key}: ${entry.value}"');
    }
    if (requestBody != null) {
      try {
        final bodyStr = requestBody is String ? requestBody : json.encode(requestBody);
        buffer.write(" -d '$bodyStr'");
      } on Object {
        buffer.write(" -d '$requestBody'");
      }
    }
    return buffer.toString();
  }
}

class NetworkInspector {
  new({this.maxEntries = 100, this.enabled = true});

  final int maxEntries;
  final bool enabled;

  final Queue<NetworkTransaction> _transactions = Queue<NetworkTransaction>();

  List<NetworkTransaction> get transactions => List.unmodifiable(_transactions);

  void logRequest(RequestOptions options) {
    // Dipersiapkan saat response/error selesai
  }

  void logResponse(Response<dynamic> response) {
    if (!enabled) return;

    final options = response.requestOptions;
    final id = options.extra['requestId']?.toString() ?? '-';
    final duration = RequestLogger.calculateDuration(options);

    final tx = NetworkTransaction(
      id: id,
      method: options.method.toUpperCase(),
      url: options.uri.toString(),
      durationMs: duration,
      timestamp: DateTime.now(),
      statusCode: response.statusCode,
      requestHeaders: RequestLogger.sanitizeHeaders(options.headers),
      requestBody: RequestLogger.sanitizeBody(options.data),
      responseBody: response.data,
    );

    _addTransaction(tx);
  }

  void logError(DioException err) {
    if (!enabled) return;

    final options = err.requestOptions;
    final id = options.extra['requestId']?.toString() ?? '-';
    final duration = RequestLogger.calculateDuration(options);

    final tx = NetworkTransaction(
      id: id,
      method: options.method.toUpperCase(),
      url: options.uri.toString(),
      durationMs: duration,
      timestamp: DateTime.now(),
      statusCode: err.response?.statusCode,
      requestHeaders: RequestLogger.sanitizeHeaders(options.headers),
      requestBody: RequestLogger.sanitizeBody(options.data),
      responseBody: err.response?.data,
      error: err.message ?? err.error?.toString(),
    );

    _addTransaction(tx);
  }

  void clear() {
    _transactions.clear();
  }

  void _addTransaction(NetworkTransaction tx) {
    if (_transactions.length >= maxEntries) {
      _transactions.removeFirst();
    }
    _transactions.addLast(tx);
  }
}
