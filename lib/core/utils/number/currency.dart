import 'package:intl/intl.dart';

abstract final class CurrencyUtils {
  static String formatIdr(num amount, {bool withSymbol = true, int decimalDigits = 0}) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: withSymbol ? 'Rp ' : '',
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  static num? parseIdr(String input) {
    final cleaned = input.replaceAll(RegExp('[^0-9,-]'), '').replaceAll(',', '.');
    return num.tryParse(cleaned);
  }
}
