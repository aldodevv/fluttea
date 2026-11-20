import 'package:fluttea/core/constants/regex.dart';

extension StringX on String {
  bool get isBlank => trim().isEmpty;

  bool get isNotBlank => trim().isNotEmpty;

  String capitalize() {
    if (isEmpty) return this;
    if (length == 1) return toUpperCase();
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String obscure({int visibleStart = 0, int visibleEnd = 0, String maskChar = '*'}) {
    if (isEmpty) return this;
    final start = visibleStart < 0 ? 0 : visibleStart;
    final end = visibleEnd < 0 ? 0 : visibleEnd;

    if (start + end >= length) {
      return this;
    }

    final startPart = substring(0, start);
    final endPart = substring(length - end);
    final maskLength = length - start - end;

    return '$startPart${maskChar * maskLength}$endPart';
  }

  int? toIntOrNull() => int.tryParse(this);

  double? toDoubleOrNull() => double.tryParse(this);

  bool get isValidEmail => AppRegex.email.hasMatch(this);

  bool get isValidPhone => AppRegex.phone.hasMatch(this);
}

extension NullableStringX on String? {
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;

  bool get isNotNullOrBlank => this != null && this!.trim().isNotEmpty;
}
