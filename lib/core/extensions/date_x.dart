import 'package:intl/intl.dart';

extension DateX on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return isSameDay(now);
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(yesterday);
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  String toDateOnlyIso() {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  String timeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 45) {
      return 'baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks minggu lalu';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months bulan lalu';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years tahun lalu';
    }
  }
}
