import 'package:fluttea/core/devtools/gallery/state_cases/case1_async_view_section.dart';
import 'package:fluttea/core/devtools/gallery/state_cases/case2_form_mutation_section.dart';
import 'package:fluttea/core/devtools/gallery/state_cases/case4_family_scoped_section.dart';
import 'package:fluttea/core/devtools/gallery/state_cases/case5_selective_rebuild_section.dart';
import 'package:fluttea/core/devtools/gallery/state_examples_screen.dart';
import 'package:fluttea/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('StateExamplesScreen', () {
    Widget buildHost(Widget child) {
      return ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: child),
        ),
      );
    }

    testWidgets('renders all 5 case sections', (tester) async {
      await tester.pumpWidget(buildHost(const StateExamplesScreen()));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('State Management Examples'), findsOneWidget);
      expect(find.text('1. AsyncView (Data / Empty / Error / Loading)'), findsOneWidget);
      expect(find.text('2. Form Mutation & Feedback'), findsOneWidget);
      expect(find.text('3. Session State & resetOn (Logout / Background)'), findsOneWidget);
      expect(find.text('4. Scoped State via Family (.family)'), findsOneWidget);
      expect(find.text('5. Selective Rebuilding (.select)'), findsOneWidget);
    });

    testWidgets('case 1: toggling error shows error view and retrying restores data', (
      tester,
    ) async {
      await tester.pumpWidget(buildHost(const Case1AsyncViewSection()));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('Laptop Pro'), findsOneWidget);

      // Tap Simulasi Error
      await tester.tap(find.text('Simulasi Error'));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('Simulasi kegagalan jaringan saat mengambil produk.'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      // Tap Coba Lagi
      await tester.tap(find.text('Coba Lagi'));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('Laptop Pro'), findsOneWidget);
    });

    testWidgets('case 2: form submission validates and shows error if too short', (tester) async {
      await tester.pumpWidget(buildHost(const Case2FormMutationSection()));
      await tester.pumpAndSettle();

      // Enter a 1-character name
      await tester.enterText(find.byType(TextFormField).first, 'A');
      await tester.tap(find.text('Simpan Profil'));
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();

      expect(find.text('Nama terlalu pendek (minimal 3 karakter).'), findsOneWidget);
    });

    testWidgets('case 4: counter items increment and decrement independently', (tester) async {
      await tester.pumpWidget(buildHost(const Case4FamilyScopedSection()));
      await tester.pumpAndSettle();

      expect(find.text('Kopi Espresso'), findsOneWidget);
      expect(find.text('Croissant Coklat'), findsOneWidget);

      final addButtons = find.byIcon(Icons.add);
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('case 5: selective title and notif updates', (tester) async {
      await tester.pumpWidget(buildHost(const Case5SelectiveRebuildSection()));
      await tester.pumpAndSettle();

      expect(find.text('Judul (selected): Developer'), findsOneWidget);
      expect(find.text('Notifikasi (selected): 3'), findsOneWidget);

      await tester.tap(find.text('Ubah Judul'));
      await tester.pumpAndSettle();
      expect(find.text('Judul (selected): Tech Lead'), findsOneWidget);

      await tester.tap(find.text('Tambah Notifikasi'));
      await tester.pumpAndSettle();
      expect(find.text('Notifikasi (selected): 4'), findsOneWidget);
    });
  });
}
