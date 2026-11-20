import 'package:fluttea/core/theme/app_theme.dart';
import 'package:fluttea/core/widgets/layout/app_scaffold.dart';
import 'package:fluttea/core/widgets/layout/keyboard_dismiss.dart';
import 'package:fluttea/core/widgets/layout/responsive_builder.dart';
import 'package:fluttea/core/widgets/layout/section.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('Layout Widgets', () {
    Widget createSubject({required Widget child}) {
      return MaterialApp(theme: AppTheme.light(), home: child);
    }

    testWidgets('AppScaffold renders body, appBar, and handles taps', (tester) async {
      await tester.pumpWidget(
        createSubject(
          child: AppScaffold(
            appBar: AppBar(title: const Text('Header')),
            body: const Text('Body Content'),
          ),
        ),
      );

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Body Content'), findsOneWidget);
      expect(find.byType(KeyboardDismiss), findsOneWidget);
    });

    testWidgets('Section renders title, subtitle, and action', (tester) async {
      await tester.pumpWidget(
        createSubject(
          child: const Scaffold(
            body: Section(
              title: 'Pengaturan Akun',
              subtitle: 'Kelola preferensi Anda',
              action: Icon(Icons.settings),
              child: Text('Isi Section'),
            ),
          ),
        ),
      );

      expect(find.text('Pengaturan Akun'), findsOneWidget);
      expect(find.text('Kelola preferensi Anda'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.text('Isi Section'), findsOneWidget);
    });

    testWidgets('ResponsiveBuilder renders mobile layout by default', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        createSubject(
          child: Scaffold(
            body: ResponsiveBuilder(
              mobile: (_) => const Text('Mobile Layout'),
              tablet: (_) => const Text('Tablet Layout'),
              desktop: (_) => const Text('Desktop Layout'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsOneWidget);
      expect(find.text('Tablet Layout'), findsNothing);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
