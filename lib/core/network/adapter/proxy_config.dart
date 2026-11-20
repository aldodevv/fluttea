import 'dart:io';

import 'package:flutter/foundation.dart';

@immutable
sealed class ProxyConfig {
  const new();

  const factory none() = _NoProxy;
  const factory system() = _SystemProxy;
  const factory manual({
    required String host,
    required int port,
    String? username,
    String? password,
  }) = _ManualProxy;
  const factory pac({required String scriptUrl}) = _PacProxy;

  bool get isNone => this is _NoProxy;
  bool get isManual => this is _ManualProxy;

  String? get proxyAddress => switch (this) {
    _ManualProxy(:final host, :final port) => '$host:$port',
    _ => null,
  };

  String findProxy(Uri uri) => switch (this) {
    _NoProxy() => 'DIRECT',
    _SystemProxy() => HttpClient.findProxyFromEnvironment(uri),
    _ManualProxy(:final host, :final port) => 'PROXY $host:$port',
    _PacProxy() => HttpClient.findProxyFromEnvironment(uri),
  };

  void applyCredentials(HttpClient client) {
    if (this case _ManualProxy(:final username?, :final password?)) {
      client.authenticateProxy = (host, port, scheme, realm) async {
        client.addProxyCredentials(
          host,
          port,
          realm ?? '',
          HttpClientBasicCredentials(username, password),
        );
        return true;
      };
    }
  }
}

final class _NoProxy extends ProxyConfig {
  const new();

  @override
  String toString() => 'ProxyConfig.none()';
}

final class _SystemProxy extends ProxyConfig {
  const new();

  @override
  String toString() => 'ProxyConfig.system()';
}

final class _ManualProxy extends ProxyConfig {
  const new({required this.host, required this.port, this.username, this.password});

  final String host;
  final int port;
  final String? username;
  final String? password;

  @override
  String get proxyAddress => '$host:$port';

  @override
  String toString() => 'ProxyConfig.manual($proxyAddress)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ManualProxy &&
          other.host == host &&
          other.port == port &&
          other.username == username &&
          other.password == password;

  @override
  int get hashCode => Object.hash(host, port, username, password);
}

final class _PacProxy extends ProxyConfig {
  const new({required this.scriptUrl});

  final String scriptUrl;

  @override
  String toString() => 'ProxyConfig.pac($scriptUrl)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _PacProxy && other.scriptUrl == scriptUrl;

  @override
  int get hashCode => scriptUrl.hashCode;
}
