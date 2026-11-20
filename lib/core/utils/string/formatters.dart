abstract final class StringFormatters {
  static String initials(String name, {int max = 2}) {
    if (name.trim().isEmpty) return '';
    final words = name.trim().split(RegExp(r'\s+'));
    final buffer = StringBuffer();
    for (var i = 0; i < words.length && i < max; i++) {
      if (words[i].isNotEmpty) {
        buffer.write(words[i][0].toUpperCase());
      }
    }
    return buffer.toString();
  }

  static String cleanNumeric(String input) {
    return input.replaceAll(RegExp('[^0-9]'), '');
  }

  static String slugify(String text) {
    final lower = text.trim().toLowerCase();
    final noSpecial = lower.replaceAll(RegExp(r'[^a-z0-9\s-]'), '');
    return noSpecial.replaceAll(RegExp(r'\s+'), '-');
  }
}
