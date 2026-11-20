import 'package:fluttea/core/theme/app_theme.dart';
import 'package:fluttea/core/widgets/security/privacy_overlay.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('PrivacyOverlay', () {
    testWidgets('shows overlay when lifecycle becomes inactive', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: PrivacyOverlay(child: Center(child: Text('Data Sensitif'))),
          ),
        ),
      );

      expect(find.text('Data Sensitif'), findsOneWidget);
      expect(find.text('Konten Terlindungi'), findsNothing);

      // Simulate app transitioning to inactive/background
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pumpAndSettle();

      expect(find.text('Konten Terlindungi'), findsOneWidget);
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);

      // Simulate returning to active
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(find.text('Konten Terlindungi'), findsNothing);
    });
  });
}
