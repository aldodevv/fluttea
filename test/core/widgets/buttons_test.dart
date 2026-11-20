import 'package:fluttea/core/theme/app_theme.dart';
import 'package:fluttea/core/widgets/buttons/app_button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('AppButton', () {
    Widget createSubject({required Widget child}) {
      return MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: Center(child: child)),
      );
    }

    testWidgets('renders label and triggers onPressed', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        createSubject(
          child: AppButton(label: 'Submit', onPressed: () => pressed = true),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
      await tester.tap(find.text('Submit'));
      expect(pressed, isTrue);
    });

    testWidgets('shows loading indicator and disables tap', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        createSubject(
          child: AppButton(
            label: 'Loading Button',
            isLoading: true,
            onPressed: () => pressed = true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Loading Button'));
      expect(pressed, isFalse);
    });

    testWidgets('renders all variants without crash', (tester) async {
      for (final variant in AppButtonVariant.values) {
        await tester.pumpWidget(
          createSubject(
            child: AppButton(label: variant.name, variant: variant, onPressed: () {}),
          ),
        );
        expect(find.text(variant.name), findsOneWidget);
      }
    });

    testWidgets('isFullWidth expands to container width', (tester) async {
      await tester.pumpWidget(
        createSubject(
          child: SizedBox(
            width: 300,
            child: AppButton(label: 'Full Width', isFullWidth: true, onPressed: () {}),
          ),
        ),
      );

      final size = tester.getSize(find.byType(AppButton));
      expect(size.width, equals(300));
    });
  });
}
