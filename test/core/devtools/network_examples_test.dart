import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fluttea/core/devtools/gallery/network_examples_screen.dart';
import 'package:fluttea/core/network/api_client.dart';
import 'package:fluttea/core/network/base_url/flavor_base_url.dart';
import 'package:fluttea/core/network/network_config.dart';
import 'package:fluttea/core/network/network_providers.dart';
import 'package:fluttea/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _MockAdapter implements HttpClientAdapter {
  new(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('NetworkExamplesScreen', () {
    late ApiClient fakeClient;

    setUp(() {
      final dio = Dio(BaseOptions(baseUrl: 'https://www.mock-server.com'))
        ..httpClientAdapter = _MockAdapter((options) async {
          final payload = json.encode({'status': 'mock_ok', 'data': 'mock_payload'});
          return ResponseBody.fromString(
            payload,
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

      fakeClient = ApiClient(
        config: const NetworkConfig(
          baseUrlResolver: FlavorBaseUrlResolver('https://www.mock-server.com'),
        ),
        dio: dio,
      );
    });

    testWidgets('renders all network sections and elements', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(fakeClient)],
          child: MaterialApp(theme: AppTheme.light(), home: const NetworkExamplesScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Network & Mock Server'), findsOneWidget);
      expect(find.text('1. Network Profile & Base URL'), findsOneWidget);
      expect(find.text('2. Request Playground'), findsOneWidget);
      expect(find.text('3. Network Inspector (Last 0 Requests)'), findsOneWidget);
      expect(find.text('GET /mock/status'), findsOneWidget);
      expect(find.text('POST /mock/users'), findsOneWidget);
    });

    testWidgets('triggers GET button and updates response view', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(fakeClient)],
          child: MaterialApp(theme: AppTheme.light(), home: const NetworkExamplesScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap GET /mock/status button
      await tester.tap(find.text('GET /mock/status'));
      await tester.pumpAndSettle();

      expect(find.textContaining('OK (Success)'), findsOneWidget);
    });
  });
}
