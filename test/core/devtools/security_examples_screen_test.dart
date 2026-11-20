import 'package:fluttea/core/devtools/gallery/security_examples_screen.dart';
import 'package:fluttea/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget buildTestableScreen() {
    return MaterialApp(theme: AppTheme.light(), home: const SecurityExamplesScreen());
  }

  group('SecurityExamplesScreen', () {
    testWidgets('renders all 4 security demonstration sections', (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(find.text('Security Showcase (Fase 06)'), findsOneWidget);
      expect(find.text('1. Dynamic Envelope Encryption'), findsOneWidget);
      expect(find.text('2. HMAC Anti-Replay Request Signature'), findsOneWidget);
      expect(find.text('3. File Guard & Zip Slip Protection'), findsOneWidget);
      expect(find.text('4. RASP Security Gate Simulator'), findsOneWidget);
    });

    testWidgets('executes encryption and displays envelope', (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      final encryptBtn = find.text('Encrypt Text');
      expect(encryptBtn, findsOneWidget);

      await tester.tap(encryptBtn);
      await tester.pumpAndSettle();

      expect(find.text('Envelope JSON:'), findsOneWidget);
    });

    testWidgets('generates HMAC signature', (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      final hmacBtn = find.text('Generate Signature');
      expect(hmacBtn, findsOneWidget);

      await tester.tap(hmacBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('HMAC Signature:'), findsOneWidget);
    });

    testWidgets('tests file guard magic bytes and zip slip detection', (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      // Test PNG
      final pngBtn = find.text('Test PNG');
      await tester.tap(pngBtn);
      await tester.pumpAndSettle();
      expect(find.textContaining('PNG Header Valid'), findsOneWidget);

      // Test Zip Slip
      final zipSlipBtn = find.text('Test Zip Slip');
      await tester.tap(zipSlipBtn);
      await tester.pumpAndSettle();
      expect(find.textContaining('DIBLOKIR: Potential Zip Slip'), findsOneWidget);
    });

    testWidgets('RASP simulator updates verdict when threat is toggled', (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      // Initial verdict with all toggles off should be allow
      expect(find.textContaining('Verdict: SecurityVerdict.allow'), findsOneWidget);

      // Toggle Root / Jailbreak checkbox
      final rootCheckbox = find.text('Root / Jailbreak');
      await tester.tap(rootCheckbox);
      await tester.pumpAndSettle();

      // Verdict should now be block
      expect(find.textContaining('Verdict: SecurityVerdict.block'), findsOneWidget);
    });
  });
}
