abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration splash = Duration(milliseconds: 1500);
  static const Duration snackbar = Duration(milliseconds: 4000);
  static const Duration debounce = Duration(milliseconds: 300);
  static const Duration throttle = Duration(milliseconds: 500);
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration tokenRefreshBuffer = Duration(minutes: 1);
}
