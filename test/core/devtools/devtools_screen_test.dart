import 'package:fluttea/app/flavor.dart';
import 'package:fluttea/app/providers.dart';
import 'package:fluttea/core/devtools/devtools_screen.dart';
import 'package:fluttea/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget buildTestableScreen({required AppFlavor flavor}) {
    return ProviderScope(
      overrides: [appEnvProvider.overrideWithValue(AppEnv.of(flavor))],
      child: MaterialApp(theme: AppTheme.light(), home: const DevToolsScreen()),
    );
  }

  group('DevToolsScreen', () {
    testWidgets('renders all 6 tabs in dev mode', (tester) async {
      await tester.pumpWidget(buildTestableScreen(flavor: AppFlavor.dev));
      await tester.pumpAndSettle();

      expect(find.text('Fluttea DevTools'), findsOneWidget);
      expect(find.text('Env'), findsOneWidget);
      expect(find.text('Network'), findsOneWidget);
      expect(find.text('Storage'), findsOneWidget);
      expect(find.text('Log'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('State'), findsOneWidget);
    });

    testWidgets('shows disabled message in prod mode', (tester) async {
      await tester.pumpWidget(buildTestableScreen(flavor: AppFlavor.prod));
      await tester.pumpAndSettle();

      expect(find.text('DevTools Dinonaktifkan'), findsOneWidget);
      expect(find.text('Fluttea DevTools'), findsNothing);
      expect(find.text('Env'), findsNothing);
    });

    testWidgets('switches between tabs on tap', (tester) async {
      await tester.pumpWidget(buildTestableScreen(flavor: AppFlavor.dev));
      await tester.pumpAndSettle();

      // Initial tab is Env
      expect(find.text('Environment Configuration'), findsOneWidget);

      // Switch to Network tab
      await tester.tap(find.text('Network'));
      await tester.pumpAndSettle();
      expect(find.text('2xx OK'), findsOneWidget);

      // Switch to Storage tab
      await tester.tap(find.text('Storage'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Total Entries:'), findsOneWidget);

      // Switch to Log tab
      await tester.tap(find.text('Log'));
      await tester.pumpAndSettle();
      expect(find.text('Warning'), findsOneWidget);

      // Switch to Security tab
      await tester.tap(find.text('Security'));
      await tester.pumpAndSettle();
      expect(find.text('Current Gate Verdict'), findsOneWidget);

      // Switch to State tab
      await tester.tap(find.text('State'));
      await tester.pumpAndSettle();
      expect(find.text('Session State (Riverpod)'), findsOneWidget);
    });
  });
}
