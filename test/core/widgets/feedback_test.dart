import 'dart:async';

import 'package:fluttea/core/theme/app_theme.dart';
import 'package:fluttea/core/widgets/buttons/app_button.dart';
import 'package:fluttea/core/widgets/feedback/app_bottom_sheet.dart';
import 'package:fluttea/core/widgets/feedback/app_dialog.dart';
import 'package:fluttea/core/widgets/feedback/app_snackbar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('Feedback Widgets', () {
    Widget createSubject({required Widget child}) {
      return MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: Center(child: child)),
      );
    }

    testWidgets('AppSnackbar shows floating snackbar with variant style', (tester) async {
      await tester.pumpWidget(
        createSubject(
          child: Builder(
            builder: (context) {
              return AppButton(
                label: 'Show Snackbar',
                onPressed: () {
                  AppSnackbar.show(
                    context,
                    'Pesanan tersimpan',
                    variant: AppSnackbarVariant.success,
                  );
                },
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Snackbar'));
      await tester.pump();
      expect(find.text('Pesanan tersimpan'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('AppDialog shows and returns user choice', (tester) async {
      bool? dialogResult;
      await tester.pumpWidget(
        createSubject(
          child: Builder(
            builder: (context) {
              return AppButton(
                label: 'Show Dialog',
                onPressed: () async {
                  dialogResult = await AppDialog.show(
                    context,
                    title: 'Hapus Data',
                    message: 'Yakin ingin menghapus?',
                    confirmLabel: 'Ya, Hapus',
                    cancelLabel: 'Batal',
                    isDestructive: true,
                  );
                },
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Data'), findsOneWidget);
      expect(find.text('Yakin ingin menghapus?'), findsOneWidget);

      await tester.tap(find.text('Ya, Hapus'));
      await tester.pumpAndSettle();

      expect(dialogResult, isTrue);
    });

    testWidgets('AppBottomSheet shows modal content', (tester) async {
      await tester.pumpWidget(
        createSubject(
          child: Builder(
            builder: (context) {
              return AppButton(
                label: 'Open Sheet',
                onPressed: () {
                  unawaited(
                    AppBottomSheet.show<void>(
                      context,
                      title: 'Pilih Opsi',
                      child: const Text('Sheet Content'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Opsi'), findsOneWidget);
      expect(find.text('Sheet Content'), findsOneWidget);
    });
  });
}
