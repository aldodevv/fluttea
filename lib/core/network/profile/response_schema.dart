import 'package:flutter/foundation.dart';

@immutable
class EnvelopeSpec {
  const new({
    this.codeKey = 'code',
    this.messageKey = 'message',
    this.dataKey = 'data',
    this.successValues = const {'SUCCESS', '0', 0, 200, 'OK'},
  });

  final String codeKey;
  final String messageKey;
  final String dataKey;
  final Set<dynamic> successValues;

  bool isSuccess(dynamic code) => successValues.contains(code);

  static const standard = EnvelopeSpec();

  static const mockServer = EnvelopeSpec(
    codeKey: 'statusCode',
    successValues: {200, 201, '200', 'SUCCESS', 'OK'},
  );
}
