import 'dart:io';

import 'package:fluttea/core/network/pinning/pin_strategy.dart';

class PinSet {
  const new({this.rules = const {}, this.failClosed = true});

  final Map<String, PinStrategy> rules;
  final bool failClosed;

  bool matches(X509Certificate? cert, String host, int port) {
    if (cert == null) return false;

    final strategy = rules[host] ?? rules['*'];
    if (strategy != null) {
      return strategy.evaluate(cert);
    }

    // Bila tidak ada rule: jika failClosed (prod) = tolak, jika non-prod = terima
    return !failClosed;
  }
}
