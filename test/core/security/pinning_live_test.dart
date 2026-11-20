import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluttea/core/network/pinning/pin_set.dart';
import 'package:fluttea/core/network/pinning/pin_strategy.dart';
import 'package:fluttea/core/network/pinning/pinned_http_client_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late int serverPort;
  const correctSpkiPin = 'PXxwDa+K/DJsU4Bcb5gfvjb9f5eBPUnroRBd9JywylE=';
  const certPath = 'test/fixtures/certs/localhost_cert.pem';
  const keyPath = 'test/fixtures/certs/localhost_key.pem';

  var serverReceivedRequests = 0;
  var serverReceivedBytes = 0;

  setUpAll(() async {
    final serverContext = SecurityContext()
      ..useCertificateChain(certPath)
      ..usePrivateKey(keyPath);

    server = await HttpServer.bindSecure(InternetAddress.loopbackIPv4, 0, serverContext);
    serverPort = server.port;

    server.listen((request) async {
      serverReceivedRequests++;
      await for (final chunk in request) {
        serverReceivedBytes += chunk.length;
      }
      request.response
        ..statusCode = HttpStatus.ok
        ..write('OK from HTTPS');
      await request.response.close();
    });
  });

  tearDownAll(() async {
    await server.close(force: true);
  });

  setUp(() {
    serverReceivedRequests = 0;
    serverReceivedBytes = 0;
  });

  Dio createPinnedDio(PinSet pinSet) {
    return Dio(
      BaseOptions(
        baseUrl: 'https://127.0.0.1:$serverPort',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    )..httpClientAdapter = PinnedHttpClientFactory.createAdapter(pinSet: pinSet);
  }

  test('Pin Benar: HTTPS request sukses terkirim dan server menerima data', () async {
    const pinSet = PinSet(
      rules: {
        '127.0.0.1': PinStrategy.spki({correctSpkiPin}),
      },
    );

    final dio = createPinnedDio(pinSet);
    final response = await dio.post<String>('/test', data: 'Hello Secure World');

    expect(response.statusCode, 200);
    expect(response.data, 'OK from HTTPS');
    expect(serverReceivedRequests, 1);
    expect(serverReceivedBytes, greaterThan(0));
  });

  test('Pin Salah: pre-send handshake gagal dan server menerima 0 BYTE request', () async {
    const wrongPin = 'WrongPinBase64AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';
    const pinSet = PinSet(
      rules: {
        '127.0.0.1': PinStrategy.spki({wrongPin}),
      },
    );

    final dio = createPinnedDio(pinSet);

    // Kirim request dengan payload rahasia
    expect(
      () => dio.post<String>('/test', data: 'Super Secret Payload Not Sent'),
      throwsA(isA<DioException>()),
    );

    // Verifikasi keras prinsip keamanan:
    // Server sama sekali tidak boleh menerima byte atau request dari client
    expect(serverReceivedRequests, 0);
    expect(serverReceivedBytes, 0);
  });

  test('Rotasi Pin: pin cadangan menerima koneksi saat primary kadaluarsa/salah', () async {
    const expiredPrimaryPin = 'OldExpiredPinAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';
    const pinSet = PinSet(
      rules: {
        '127.0.0.1': PinStrategy.spki({expiredPrimaryPin, correctSpkiPin}),
      },
    );

    final dio = createPinnedDio(pinSet);
    final response = await dio.get<String>('/test');

    expect(response.statusCode, 200);
    expect(serverReceivedRequests, 1);
  });
}
