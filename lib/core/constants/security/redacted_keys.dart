abstract final class RedactedKeys {
  static const Set<String> headers = {
    'authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
    'proxy-authorization',
  };

  static const Set<String> bodyFields = {
    'password',
    'pin',
    'otp',
    'token',
    'access_token',
    'refresh_token',
    'secret',
    'card_number',
    'cvv',
  };
}
