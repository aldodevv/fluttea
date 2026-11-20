import 'dart:async';

import 'package:fluttea/core/constants/security/security_consts.dart';
import 'package:flutter/services.dart';

final class ClipboardGuard {
  new();

  Timer? _clearTimer;
  String? _lastSensitiveContent;

  Future<void> copySensitive(
    String text, {
    Duration clearAfter = SecurityConsts.defaultClipboardClearDelay,
  }) async {
    _clearTimer?.cancel();
    _lastSensitiveContent = text;

    await Clipboard.setData(ClipboardData(text: text));

    _clearTimer = Timer(clearAfter, () async {
      await clearIfMatches(text);
    });
  }

  Future<void> clearIfMatches(String expectedText) async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text == expectedText) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    } on Object {
      // Platform clipboard access failure handled gracefully
    } finally {
      if (_lastSensitiveContent == expectedText) {
        _lastSensitiveContent = null;
      }
      _clearTimer?.cancel();
      _clearTimer = null;
    }
  }

  Future<void> clear() async {
    _clearTimer?.cancel();
    _clearTimer = null;
    _lastSensitiveContent = null;
    try {
      await Clipboard.setData(const ClipboardData(text: ''));
    } on Object {
      // Platform clipboard access failure handled gracefully
    }
  }

  void dispose() {
    _clearTimer?.cancel();
    _clearTimer = null;
  }
}
