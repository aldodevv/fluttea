abstract final class PiiMasker {
  static const Set<String> sensitiveKeys = {
    'password',
    'pass',
    'token',
    'access_token',
    'refresh_token',
    'id_token',
    'secret',
    'client_secret',
    'api_key',
    'apikey',
    'authorization',
    'pin',
    'cvv',
    'cvc',
    'card_number',
    'pan',
    'otp',
    'private_key',
  };

  static String maskString(String input) {
    if (input.isEmpty) return input;

    var sanitized = input;

    // Mask Authorization Bearer tokens
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'(Bearer\s+)([A-Za-z0-9\-_\.=]+)', caseSensitive: false),
      (match) => '${match.group(1)}[REDACTED_TOKEN]',
    );

    // Mask Emails
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})'),
      (match) {
        final name = match.group(1) ?? '';
        final domain = match.group(2) ?? '';
        final tld = match.group(3) ?? '';
        final maskedName = name.length <= 2 ? '**' : '${name.substring(0, 2)}***';
        return '$maskedName@$domain.$tld';
      },
    );

    // Mask Phone numbers (10-15 digits)
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'(\+?[0-9]{2,4})[0-9]{3,8}([0-9]{4})'),
      (match) => '${match.group(1)}****${match.group(2)}',
    );

    return sanitized;
  }

  static Map<String, dynamic> maskMap(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    for (final entry in map.entries) {
      final key = entry.key.toLowerCase();
      final value = entry.value;

      if (sensitiveKeys.contains(key)) {
        result[entry.key] = '[REDACTED]';
      } else if (value is Map<String, dynamic>) {
        result[entry.key] = maskMap(value);
      } else if (value is List) {
        result[entry.key] = _maskList(value);
      } else if (value is String) {
        result[entry.key] = maskString(value);
      } else {
        result[entry.key] = value;
      }
    }
    return result;
  }

  static List<dynamic> _maskList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map<String, dynamic>) {
        return maskMap(item);
      } else if (item is List) {
        return _maskList(item);
      } else if (item is String) {
        return maskString(item);
      }
      return item;
    }).toList();
  }
}
