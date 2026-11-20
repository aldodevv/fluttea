import 'package:flutter/services.dart';

abstract interface class ScreenProtector {
  Future<void> enableSecureScreen();
  Future<void> disableSecureScreen();
  Future<bool> isScreenCaptured();
}

final class PlatformScreenProtector implements ScreenProtector {
  const new({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('fluttea/screen_privacy');

  final MethodChannel _channel;

  @override
  Future<void> enableSecureScreen() async {
    try {
      await _channel.invokeMethod<void>('enableSecureScreen');
    } on MissingPluginException {
      // Ignored in test/headless environments
    }
  }

  @override
  Future<void> disableSecureScreen() async {
    try {
      await _channel.invokeMethod<void>('disableSecureScreen');
    } on MissingPluginException {
      // Ignored in test/headless environments
    }
  }

  @override
  Future<bool> isScreenCaptured() async {
    try {
      final result = await _channel.invokeMethod<bool>('isScreenCaptured');
      return result ?? false;
    } on MissingPluginException {
      return false;
    }
  }
}

final class MockScreenProtector implements ScreenProtector {
  new({this.isSecured = false, this.isCaptured = false});

  bool isSecured;
  bool isCaptured;

  @override
  Future<void> enableSecureScreen() async {
    isSecured = true;
  }

  @override
  Future<void> disableSecureScreen() async {
    isSecured = false;
  }

  @override
  Future<bool> isScreenCaptured() async => isCaptured;
}
