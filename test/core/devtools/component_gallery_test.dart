import 'package:fluttea/core/devtools/gallery/component_gallery_screen.dart';
import 'package:fluttea/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('ComponentGalleryScreen', () {
    testWidgets('renders all major sections and components', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: const ComponentGalleryScreen(),
        ),
      );

      expect(find.text('Komponen UI Gallery'), findsOneWidget);
      expect(find.text('Buttons (Variants & States)'), findsOneWidget);
      expect(find.text('Inputs'), findsOneWidget);
      expect(find.text('Feedback (Snackbar, Dialog, Sheet)'), findsOneWidget);
      expect(find.text('Loading & Skeletons'), findsOneWidget);
      expect(find.text('Avatars'), findsOneWidget);
      expect(find.text('State Views (Empty & Error)'), findsOneWidget);
    });
  });
}
