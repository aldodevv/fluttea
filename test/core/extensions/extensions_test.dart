import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/extensions/date_x.dart';
import 'package:fluttea/core/extensions/num_x.dart';
import 'package:fluttea/core/extensions/string_x.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('StringX and NullableStringX', () {
    test('isBlank and isNotBlank', () {
      expect(''.isBlank, isTrue);
      expect('   '.isBlank, isTrue);
      expect('hello'.isBlank, isFalse);
      expect('hello'.isNotBlank, isTrue);
    });

    test('capitalize', () {
      expect('fluttea'.capitalize(), equals('Fluttea'));
      expect('F'.capitalize(), equals('F'));
      expect(''.capitalize(), equals(''));
    });

    test('obscure', () {
      expect('1234567890'.obscure(visibleStart: 2, visibleEnd: 2), equals('12******90'));
      expect('short'.obscure(visibleStart: 3, visibleEnd: 3), equals('short'));
    });

    test('toIntOrNull and toDoubleOrNull', () {
      expect('42'.toIntOrNull(), equals(42));
      expect('abc'.toIntOrNull(), isNull);
      expect('3.14'.toDoubleOrNull(), equals(3.14));
      expect('abc'.toDoubleOrNull(), isNull);
    });

    test('isValidEmail and isValidPhone', () {
      expect('user@test.com'.isValidEmail, isTrue);
      expect('user@'.isValidEmail, isFalse);
      expect('+628123456789'.isValidPhone, isTrue);
      expect('not_a_phone'.isValidPhone, isFalse);
    });

    test('NullableStringX', () {
      const String? nullStr = null;
      const emptyStr = '   ';
      const validStr = 'Fluttea';

      expect(nullStr.isNullOrBlank, isTrue);
      expect(emptyStr.isNullOrBlank, isTrue);
      expect(validStr.isNullOrBlank, isFalse);

      expect(validStr.isNotNullOrBlank, isTrue);
      expect(emptyStr.isNotNullOrBlank, isFalse);
      expect(nullStr.isNotNullOrBlank, isFalse);
    });
  });

  group('NumX', () {
    test('toCurrencyIdr formats correctly', () {
      expect(10000.toCurrencyIdr(), contains('10.000'));
      expect(10000.toCurrencyIdr(withSymbol: false), isNot(contains('Rp')));
    });

    test('gapW and gapH create SizedBox widgets', () {
      final w = 16.gapW;
      final h = 24.gapH;

      expect(w, isA<SizedBox>());
      expect((w as SizedBox).width, equals(16.0));
      expect(h, isA<SizedBox>());
      expect((h as SizedBox).height, equals(24.0));
    });
  });

  group('DateX', () {
    test('isToday and isYesterday', () {
      final now = DateTime.now();
      expect(now.isToday, isTrue);
      expect(now.isYesterday, isFalse);

      final yesterday = now.subtract(const Duration(days: 1));
      expect(yesterday.isYesterday, isTrue);
      expect(yesterday.isToday, isFalse);
    });

    test('toDateOnlyIso formats yyyy-MM-dd', () {
      final date = DateTime(2026, 11, 14);
      expect(date.toDateOnlyIso(), equals('2026-11-14'));
    });

    test('timeAgo returns relative descriptions', () {
      final now = DateTime.now();
      expect(now.subtract(const Duration(seconds: 10)).timeAgo(), equals('baru saja'));
      expect(now.subtract(const Duration(minutes: 5)).timeAgo(), equals('5 menit lalu'));
      expect(now.subtract(const Duration(hours: 3)).timeAgo(), equals('3 jam lalu'));
      expect(now.subtract(const Duration(days: 2)).timeAgo(), equals('2 hari lalu'));
    });
  });

  group('ContextX', () {
    testWidgets('provides shortcuts to Theme and MediaQuery', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedContext.theme, isNotNull);
      expect(capturedContext.colors, isNotNull);
      expect(capturedContext.textTheme, isNotNull);
      expect(capturedContext.isDarkMode, isFalse);
      expect(capturedContext.screenWidth, greaterThan(0));
      expect(capturedContext.screenHeight, greaterThan(0));
    });
  });
}
