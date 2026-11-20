import 'dart:async';

import 'package:fluttea/core/errors/failure.dart';
import 'package:fluttea/core/state/async_view.dart';
import 'package:fluttea/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('AsyncView', () {
    Widget createSubject({required Widget child}) {
      return MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: child),
      );
    }

    testWidgets('renders data when AsyncData', (tester) async {
      const value = AsyncData(['Item 1', 'Item 2']);

      await tester.pumpWidget(
        createSubject(
          child: AsyncView<List<String>>(
            value: value,
            data: (list) => Column(children: list.map(Text.new).toList()),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });

    testWidgets('renders default AppLoader when AsyncLoading', (tester) async {
      const AsyncValue<String> value = AsyncLoading();

      await tester.pumpWidget(
        createSubject(
          child: const AsyncView<String>(value: value, data: Text.new),
        ),
      );

      expect(find.text('Memuat data...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders default ErrorView with retry button when AsyncError', (tester) async {
      var retried = false;
      const AsyncValue<String> value = AsyncError(
        NetworkFailure(message: 'Tidak ada koneksi'),
        StackTrace.empty,
      );

      await tester.pumpWidget(
        createSubject(
          child: AsyncView<String>(value: value, onRetry: () => retried = true, data: Text.new),
        ),
      );

      expect(find.text('Tidak ada koneksi'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      expect(retried, isTrue);
    });

    testWidgets('renders empty view when isEmpty returns true', (tester) async {
      const value = AsyncData(<String>[]);

      await tester.pumpWidget(
        createSubject(
          child: AsyncView<List<String>>(
            value: value,
            isEmpty: (list) => list.isEmpty,
            data: (list) => const Text('Has data'),
          ),
        ),
      );

      expect(find.text('Tidak Ada Data'), findsOneWidget);
      expect(find.text('Has data'), findsNothing);
    });

    testWidgets('keeps showing data during refresh if showLoadingOnRefresh is false', (
      tester,
    ) async {
      var callCount = 0;
      final completer = Completer<String>();
      final provider = FutureProvider<String>((ref) {
        if (callCount++ == 0) return 'Cached Data';
        return completer.future;
      });

      await tester.pumpWidget(
        ProviderScope(
          child: createSubject(
            child: Consumer(
              builder: (context, ref, _) {
                final val = ref.watch(provider);
                return AsyncView<String>(value: val, data: Text.new);
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Cached Data'), findsOneWidget);

      ProviderScope.containerOf(tester.element(find.byType(Consumer))).refresh(provider);
      await tester.pump();

      // Still displays Cached Data while refreshing because showLoadingOnRefresh is false
      expect(find.text('Cached Data'), findsOneWidget);
      expect(find.text('Memuat data...'), findsNothing);

      completer.complete('New Data');
      await tester.pumpAndSettle();
      expect(find.text('New Data'), findsOneWidget);
    });
  });
}
