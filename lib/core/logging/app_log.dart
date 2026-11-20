import 'package:fluttea/core/logging/pii_masker.dart';
import 'package:talker/talker.dart';

abstract final class AppLog {
  static Talker _talker = Talker(settings: TalkerSettings(maxHistoryItems: 200));

  static Talker get talker => _talker;

  static void init({
    bool enabled = true,
    LogLevel minLevel = LogLevel.debug,
    TalkerObserver? observer,
    TalkerLogger? customLogger,
  }) {
    _talker = Talker(
      settings: TalkerSettings(enabled: enabled, maxHistoryItems: 200),
      logger: customLogger ?? TalkerLogger(settings: TalkerLoggerSettings(level: minLevel)),
      observer: observer,
    );
  }

  static void v(String message, {String? tag}) {
    _talker.verbose(_format(message, tag));
  }

  static void d(String message, {String? tag}) {
    _talker.debug(_format(message, tag));
  }

  static void i(String message, {String? tag}) {
    _talker.info(_format(message, tag));
  }

  static void w(String message, {String? tag, Object? exception, StackTrace? stackTrace}) {
    _talker.warning(_format(message, tag), exception, stackTrace);
  }

  static void e(String message, {String? tag, Object? exception, StackTrace? stackTrace}) {
    _talker.error(_format(message, tag), exception, stackTrace);
  }

  static void critical(String message, {String? tag, Object? exception, StackTrace? stackTrace}) {
    _talker.critical(_format(message, tag), exception, stackTrace);
  }

  static void handle(Object error, [StackTrace? stackTrace, String? message]) {
    final sanitizedMessage = message != null ? PiiMasker.maskString(message) : null;
    _talker.handle(error, stackTrace, sanitizedMessage);
  }

  static String _format(String message, String? tag) {
    final masked = PiiMasker.maskString(message);
    if (tag != null && tag.isNotEmpty) {
      return '[$tag] $masked';
    }
    return masked;
  }
}
