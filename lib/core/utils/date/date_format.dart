import 'dart:async';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

abstract final class AppDateFormat {
  static bool _isInitialized = false;

  static void ensureInitialized() {
    if (!_isInitialized) {
      unawaited(initializeDateFormatting('id_ID'));
      _isInitialized = true;
    }
  }

  static String format(DateTime date, {String pattern = 'dd MMM yyyy', String locale = 'id_ID'}) {
    ensureInitialized();
    return DateFormat(pattern, locale).format(date);
  }

  static String formatDate(DateTime date) {
    return format(date, pattern: 'dd MMMM yyyy');
  }

  static String formatDateTime(DateTime date) {
    return format(date, pattern: 'dd MMM yyyy, HH:mm');
  }

  static String formatTime(DateTime date) {
    return format(date, pattern: 'HH:mm');
  }

  static DateTime? tryParse(String input) {
    return DateTime.tryParse(input);
  }
}
