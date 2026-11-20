abstract final class QueryEncoder {
  static String encode(Map<String, dynamic> params) {
    if (params.isEmpty) return '';

    final pairs = <String>[];
    for (final entry in params.entries) {
      final key = Uri.encodeQueryComponent(entry.key);
      final value = entry.value;

      if (value == null) continue;

      if (value is Iterable) {
        for (final item in value) {
          if (item != null) {
            pairs.add('$key=${Uri.encodeQueryComponent(item.toString())}');
          }
        }
      } else {
        pairs.add('$key=${Uri.encodeQueryComponent(value.toString())}');
      }
    }

    return pairs.join('&');
  }
}
