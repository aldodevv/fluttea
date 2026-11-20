import 'package:fluttea/core/utils/date/date_format.dart';
import 'package:fluttea/core/utils/debounce.dart';
import 'package:fluttea/core/utils/network/query_encoder.dart';
import 'package:fluttea/core/utils/network/url_builder.dart';
import 'package:fluttea/core/utils/number/currency.dart';
import 'package:fluttea/core/utils/platform/platform_info.dart';
import 'package:fluttea/core/utils/string/formatters.dart';
import 'package:fluttea/core/utils/string/masking.dart';
import 'package:fluttea/core/utils/string/validators.dart';
import 'package:fluttea/core/utils/throttle.dart';
import 'package:fluttea/core/utils/ui/haptics.dart';
import 'package:fluttea/core/utils/ui/keyboard.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('String Utils & Validators', () {
    test('MaskingUtils masks email and phone', () {
      expect(MaskingUtils.maskEmail('user@test.com'), equals('us***@test.com'));
      expect(MaskingUtils.maskPhone('+628123456789'), equals('+6281****6789'));
      expect(MaskingUtils.maskString('1234567890'), equals('12******90'));
      expect(MaskingUtils.maskString('abc'), equals('***'));
    });

    test('Validators validate required, email, phone, length, and match', () {
      expect(Validators.required(''), isNotNull);
      expect(Validators.required('text'), isNull);

      expect(Validators.email('invalid'), isNotNull);
      expect(Validators.email('valid@fluttea.com'), isNull);

      expect(Validators.phone('abc'), isNotNull);
      expect(Validators.phone('+628123456789'), isNull);

      expect(Validators.minLength('ab', 3), isNotNull);
      expect(Validators.minLength('abc', 3), isNull);

      expect(Validators.maxLength('abcd', 3), isNotNull);
      expect(Validators.maxLength('abc', 3), isNull);

      expect(Validators.match('pass1', 'pass2'), isNotNull);
      expect(Validators.match('pass1', 'pass1'), isNull);
    });

    test('StringFormatters formats initials, cleanNumeric, and slugify', () {
      expect(StringFormatters.initials('Aldo Developer'), equals('AD'));
      expect(StringFormatters.cleanNumeric('Rp 120.000,-'), equals('120000'));
      expect(StringFormatters.slugify('Hello Fluttea World!'), equals('hello-fluttea-world'));
    });
  });

  group('Number & Date Utils', () {
    test('CurrencyUtils formatIdr and parseIdr', () {
      expect(CurrencyUtils.formatIdr(50000), contains('50.000'));
      expect(CurrencyUtils.parseIdr('Rp 50.000'), equals(50000));
    });

    test('AppDateFormat formats dates', () {
      final date = DateTime(2026, 11, 14, 15, 30);
      expect(AppDateFormat.format(date), contains('14'));
      expect(AppDateFormat.formatDate(date), contains('November'));
      expect(AppDateFormat.formatTime(date), equals('15:30'));
    });
  });

  group('Network Utils', () {
    test('UrlBuilder combines base, path, and query parameters cleanly', () {
      final uri = UrlBuilder.build(
        baseUrl: 'https://api.fluttea.example',
        path: '/v1/users',
        queryParameters: {'page': 1, 'limit': 20, 'filter': null},
      );

      expect(uri.toString(), equals('https://api.fluttea.example/v1/users?page=1&limit=20'));
    });

    test('QueryEncoder encodes maps and iterables', () {
      final encoded = QueryEncoder.encode({
        'sort': 'asc',
        'tags': ['dart', 'flutter'],
        'empty': null,
      });

      expect(encoded, equals('sort=asc&tags=dart&tags=flutter'));
    });
  });

  group('Platform, Debounce, Throttle & UI', () {
    test('PlatformInfo exposes name and mobile/desktop flags', () {
      expect(PlatformInfo.name, isNotEmpty);
      expect(PlatformInfo.isWeb, isFalse);
    });

    test('Debouncer debounces multiple calls', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 30));
      var count = 0;

      debouncer
        ..run(() => count++)
        ..run(() => count++)
        ..run(() => count++);

      expect(count, equals(0));
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(count, equals(1));
      debouncer.dispose();
    });

    test('Throttler throttles subsequent calls within duration', () async {
      final throttler = Throttler(duration: const Duration(milliseconds: 50));
      var count = 0;

      throttler
        ..run(() => count++)
        ..run(() => count++)
        ..run(() => count++);

      expect(count, equals(1));
      await Future<void>.delayed(const Duration(milliseconds: 70));
      throttler.run(() => count++);
      expect(count, equals(2));
      throttler.dispose();
    });

    testWidgets('KeyboardUtils and HapticUtils can be called without crash', (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async => null,
      );
      KeyboardUtils.dismiss();
      await HapticUtils.selectionClick();
      await HapticUtils.lightImpact();
      await HapticUtils.mediumImpact();
      await HapticUtils.heavyImpact();
      await HapticUtils.vibrate();
    });
  });
}
