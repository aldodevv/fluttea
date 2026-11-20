import 'package:fluttea/core/state/route_scope.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

final testScopedProvider = Provider<String>((ref) => 'global_value');

void main() {
  group('RouteScope', () {
    testWidgets('provides scoped overrides and disposes on unmount', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: RouteScope(
              overrides: [testScopedProvider.overrideWithValue('scoped_route_value')],
              child: Consumer(
                builder: (context, ref, _) {
                  return Text(ref.watch(testScopedProvider));
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('scoped_route_value'), findsOneWidget);
    });
  });
}
