import 'package:fluttea/app/flavor.dart';
import 'package:fluttea/app/providers.dart';
import 'package:fluttea/core/devtools/tabs/env_tab.dart';
import 'package:fluttea/core/devtools/tabs/log_tab.dart';
import 'package:fluttea/core/devtools/tabs/security_tab.dart';
import 'package:fluttea/core/devtools/tabs/state_tab.dart';
import 'package:fluttea/core/devtools/tabs/storage_tab.dart';
import 'package:fluttea/core/logging/app_log.dart';
import 'package:fluttea/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget wrapWithScope(Widget child) {
    return ProviderScope(
      overrides: [appEnvProvider.overrideWithValue(AppEnv.of(AppFlavor.dev))],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: child),
      ),
    );
  }

  group('DevTools Individual Tabs', () {
    testWidgets('EnvTab renders info and action chips', (tester) async {
      await tester.pumpWidget(wrapWithScope(const EnvTab()));
      await tester.pumpAndSettle();

      expect(find.text('Environment Configuration'), findsOneWidget);
      expect(find.text('Flavor: dev'), findsOneWidget);
      expect(find.text('Base URL Override'), findsOneWidget);
      expect(find.text('Mock Server'), findsOneWidget);
      expect(find.text('Simpan Override'), findsOneWidget);
    });

    testWidgets('StorageTab displays entries and refresh button', (tester) async {
      await tester.pumpWidget(wrapWithScope(const StorageTab()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Total Entries:'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('LogTab displays logs and filters', (tester) async {
      AppLog.i('Message For DevTools Tab Test');

      await tester.pumpWidget(wrapWithScope(const LogTab()));
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Info'), findsOneWidget);
      expect(find.text('Warning'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.textContaining('Message For DevTools Tab Test'), findsOneWidget);
    });

    testWidgets('SecurityTab updates verdict on threat toggle', (tester) async {
      await tester.pumpWidget(wrapWithScope(const SecurityTab()));
      await tester.pumpAndSettle();

      expect(find.text('Current Gate Verdict'), findsOneWidget);
      expect(find.text('Root / Jailbreak'), findsOneWidget);

      // Initially allow
      expect(find.text('Allow'), findsOneWidget);

      // Toggle Root
      await tester.tap(find.text('Root / Jailbreak'));
      await tester.pumpAndSettle();

      // Verdict becomes Block
      expect(find.text('Block'), findsOneWidget);
    });

    testWidgets('StateTab simulates login and expiry', (tester) async {
      await tester.pumpWidget(wrapWithScope(const StateTab()));
      await tester.pumpAndSettle();

      expect(find.text('Session State (Riverpod)'), findsOneWidget);
      expect(find.text('Simulate Login'), findsOneWidget);

      // Tap Simulate Login
      await tester.tap(find.text('Simulate Login'));
      await tester.pumpAndSettle();

      expect(find.text('Authenticated'), findsOneWidget);

      // Tap Simulate Expiry
      await tester.tap(find.text('Simulate Expiry'));
      await tester.pumpAndSettle();

      expect(find.text('Expired'), findsOneWidget);
    });
  });
}
