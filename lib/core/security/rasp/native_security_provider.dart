import 'package:fluttea/core/security/rasp/generated/security_api.g.dart';
import 'package:fluttea/core/security/rasp/security_provider.dart';
import 'package:fluttea/core/security/rasp/security_signals.dart';
import 'package:flutter/services.dart';

final class NativeSecurityProvider implements SecurityProvider {
  new({SecurityHostApi? api}) : _api = api ?? SecurityHostApi();

  final SecurityHostApi _api;

  @override
  Future<SecuritySignals> inspect() async {
    try {
      final dto = await _api.inspectSignals();
      return SecuritySignals(
        isRootedOrJailbroken: dto.isRootedOrJailbroken,
        isEmulator: dto.isEmulator,
        isDebuggerAttached: dto.isDebuggerAttached,
        hasHookingFramework: dto.hasHookingFramework,
        isTampered: dto.isTampered,
        isUnofficialStore: dto.isUnofficialStore,
        isVpnActive: dto.isVpnActive,
        hasProxyConfigured: dto.hasProxyConfigured,
        isDevModeEnabled: dto.isDevModeEnabled,
        isScreenCaptured: dto.isScreenCaptured,
        isMockLocation: dto.isMockLocation,
      );
    } on MissingPluginException {
      return const SecuritySignals();
    } on PlatformException {
      return const SecuritySignals();
    }
  }
}
