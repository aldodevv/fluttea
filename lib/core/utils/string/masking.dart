import 'package:fluttea/core/logging/pii_masker.dart';

abstract final class MaskingUtils {
  static String maskEmail(String email) => PiiMasker.maskString(email);

  static String maskPhone(String phone) => PiiMasker.maskString(phone);

  static String maskString(String input, {int visibleStart = 2, int visibleEnd = 2}) {
    if (input.length <= visibleStart + visibleEnd) {
      return '*' * input.length;
    }
    final start = input.substring(0, visibleStart);
    final end = input.substring(input.length - visibleEnd);
    final masked = '*' * (input.length - visibleStart - visibleEnd);
    return '$start$masked$end';
  }
}
