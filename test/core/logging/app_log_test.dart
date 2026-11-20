import 'package:fluttea/core/logging/app_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLog', () {
    test('initializes and provides talker instance', () {
      AppLog.init();
      expect(AppLog.talker, isNotNull);
      expect(AppLog.talker.settings.enabled, isTrue);
    });

    test('logs without throwing and records in history', () {
      AppLog.init();
      AppLog.v('verbose message', tag: 'Test');
      AppLog.d('debug message', tag: 'Test');
      AppLog.i('info message', tag: 'Test');
      AppLog.w('warning message', tag: 'Test');
      AppLog.e('error message', tag: 'Test');
      AppLog.critical('critical message', tag: 'Test');
      AppLog.handle(Exception('sample error'), null, 'Handled error');

      expect(AppLog.talker.history.isNotEmpty, isTrue);
    });

    test('masks PII when logging', () {
      AppLog.init();
      AppLog.i('User test@fluttea.com with Bearer eyJ123456789', tag: 'Auth');

      final lastLog = AppLog.talker.history.last.generateTextMessage();
      expect(lastLog, contains('te***@fluttea.com'));
      expect(lastLog, contains('Bearer [REDACTED_TOKEN]'));
    });
  });
}
