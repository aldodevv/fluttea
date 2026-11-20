import 'package:fluttea/core/constants/regex.dart';

abstract final class Validators {
  static String? required(String? value, [String message = 'Bagian ini wajib diisi']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value, [String message = 'Format email tidak valid']) {
    if (value == null || value.trim().isEmpty) return null;
    if (!AppRegex.email.hasMatch(value.trim())) {
      return message;
    }
    return null;
  }

  static String? phone(String? value, [String message = 'Format nomor telepon tidak valid']) {
    if (value == null || value.trim().isEmpty) return null;
    if (!AppRegex.phone.hasMatch(value.trim())) {
      return message;
    }
    return null;
  }

  static String? minLength(String? value, int min, [String? message]) {
    if (value == null || value.isEmpty) return null;
    if (value.length < min) {
      return message ?? 'Minimal $min karakter';
    }
    return null;
  }

  static String? maxLength(String? value, int max, [String? message]) {
    if (value == null || value.isEmpty) return null;
    if (value.length > max) {
      return message ?? 'Maksimal $max karakter';
    }
    return null;
  }

  static String? match(String? value, String? target, [String message = 'Nilai tidak cocok']) {
    if (value != target) {
      return message;
    }
    return null;
  }
}
