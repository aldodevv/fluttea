import 'package:fluttea/app/flavor.dart';
import 'package:fluttea/app/providers.dart';
import 'package:fluttea/core/devtools/widgets/devtools_badge.dart';
import 'package:fluttea/core/devtools/widgets/devtools_trigger.dart';
import 'package:fluttea/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('DevTools Widgets', () {
    testWidgets('DevToolsBadge renders in dev mode and hides in prod mode', (tester) async {
      // Dev mode
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appEnvProvider.overrideWithValue(AppEnv.of(AppFlavor.dev))],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(body: Stack(children: [DevToolsBadge()])),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('DEVTOOLS'), findsOneWidget);

      // Prod mode
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appEnvProvider.overrideWithValue(AppEnv.of(AppFlavor.prod))],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(body: Stack(children: [DevToolsBadge()])),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('DEVTOOLS'), findsNothing);
    });

    testWidgets('DevToolsTrigger renders child and passes through events', (tester) async {
      var childTapped = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appEnvProvider.overrideWithValue(AppEnv.of(AppFlavor.dev))],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: DevToolsTrigger(
                child: GestureDetector(
                  onTap: () => childTapped = true,
                  child: const Text('Target Child'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Target Child'), findsOneWidget);
      await tester.tap(find.text('Target Child'));
      await tester.pumpAndSettle();

      expect(childTapped, isTrue);
    });
  });
}
