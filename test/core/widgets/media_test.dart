import 'package:fluttea/core/theme/app_theme.dart';
import 'package:fluttea/core/widgets/media/app_avatar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('Media Widgets', () {
    Widget createSubject({required Widget child}) {
      return MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: Center(child: child)),
      );
    }

    testWidgets('AppAvatar renders initials when no imageUrl', (tester) async {
      await tester.pumpWidget(createSubject(child: const AppAvatar(name: 'Aldo Developer')));

      expect(find.text('AD'), findsOneWidget);
    });

    testWidgets('AppAvatar renders default person icon if no name or imageUrl', (tester) async {
      await tester.pumpWidget(createSubject(child: const AppAvatar()));

      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });
}
