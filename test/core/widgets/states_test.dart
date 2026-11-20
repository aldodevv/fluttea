import 'package:fluttea/core/theme/app_theme.dart';
import 'package:fluttea/core/widgets/loading/app_loader.dart';
import 'package:fluttea/core/widgets/loading/skeleton.dart';
import 'package:fluttea/core/widgets/states/empty_view.dart';
import 'package:fluttea/core/widgets/states/error_view.dart';
import 'package:fluttea/core/widgets/states/offline_banner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('States & Loading Widgets', () {
    Widget createSubject({required Widget child}) {
      return MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: Center(child: child)),
      );
    }

    testWidgets('EmptyView displays title, message, and action', (tester) async {
      var actionTriggered = false;
      await tester.pumpWidget(
        createSubject(
          child: EmptyView(
            title: 'Data Kosong',
            message: 'Tidak ada data yang tersedia.',
            actionLabel: 'Tambah Data',
            onAction: () => actionTriggered = true,
          ),
        ),
      );

      expect(find.text('Data Kosong'), findsOneWidget);
      expect(find.text('Tidak ada data yang tersedia.'), findsOneWidget);
      expect(find.text('Tambah Data'), findsOneWidget);

      await tester.tap(find.text('Tambah Data'));
      expect(actionTriggered, isTrue);
    });

    testWidgets('ErrorView displays message and triggers retry', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        createSubject(
          child: ErrorView(message: 'Koneksi gagal', onRetry: () => retried = true),
        ),
      );

      expect(find.text('Terjadi Kesalahan'), findsOneWidget);
      expect(find.text('Koneksi gagal'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      expect(retried, isTrue);
    });

    testWidgets('OfflineBanner renders when offline', (tester) async {
      await tester.pumpWidget(createSubject(child: const OfflineBanner()));

      expect(find.text('Koneksi internet terputus'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('AppLoader displays message and indicator', (tester) async {
      await tester.pumpWidget(
        createSubject(child: const AppLoader(message: 'Sedang memuat data...')),
      );

      expect(find.text('Sedang memuat data...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Skeleton renders and animates', (tester) async {
      await tester.pumpWidget(createSubject(child: const Skeleton(height: 24, width: 120)));

      expect(find.byType(Skeleton), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(Skeleton), findsOneWidget);
    });
  });
}
