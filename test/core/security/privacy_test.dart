import 'package:fluttea/core/security/privacy/clipboard_guard.dart';
import 'package:fluttea/core/security/privacy/screen_protector.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MockScreenProtector', () {
    test('enables and disables screen security flag', () async {
      final protector = MockScreenProtector();
      expect(protector.isSecured, isFalse);

      await protector.enableSecureScreen();
      expect(protector.isSecured, isTrue);

      await protector.disableSecureScreen();
      expect(protector.isSecured, isFalse);
    });

    test('tracks screen capture status', () async {
      final protector = MockScreenProtector();
      expect(await protector.isScreenCaptured(), isFalse);

      protector.isCaptured = true;
      expect(await protector.isScreenCaptured(), isTrue);
    });
  });

  group('ClipboardGuard', () {
    late ClipboardGuard guard;
    String? mockClipboardText;

    setUp(() {
      guard = ClipboardGuard();
      mockClipboardText = null;

      // Mock SystemChannels.platform for clipboard
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            final args = call.arguments as Map;
            mockClipboardText = args['text'] as String?;
            return null;
          } else if (call.method == 'Clipboard.getData') {
            return {'text': mockClipboardText};
          }
          return null;
        },
      );
    });

    tearDown(() {
      guard.dispose();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    test('copySensitive sets text on system clipboard', () async {
      await guard.copySensitive('secret_otp_9999');
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      expect(data?.text, 'secret_otp_9999');
    });

    test('clear wipes text immediately', () async {
      await guard.copySensitive('sensitive_data');
      await guard.clear();

      final data = await Clipboard.getData(Clipboard.kTextPlain);
      expect(data?.text, isEmpty);
    });

    test('auto-clears clipboard after duration', () async {
      await guard.copySensitive('ephemeral_pin', clearAfter: const Duration(milliseconds: 50));

      final immediate = await Clipboard.getData(Clipboard.kTextPlain);
      expect(immediate?.text, 'ephemeral_pin');

      await Future<void>.delayed(const Duration(milliseconds: 80));

      final afterDelay = await Clipboard.getData(Clipboard.kTextPlain);
      expect(afterDelay?.text, isEmpty);
    });
  });
}
