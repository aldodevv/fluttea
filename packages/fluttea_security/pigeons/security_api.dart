import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/core/security/rasp/generated/security_api.g.dart',
    kotlinOut:
        'packages/fluttea_security/android/src/main/kotlin/com/fluttea/security/SecurityApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.fluttea.security'),
    swiftOut: 'packages/fluttea_security/ios/fluttea_security/Sources/SecurityApi.g.swift',
  ),
)
class NativeSecuritySignalsDto {
  new({
    this.isRootedOrJailbroken = false,
    this.isEmulator = false,
    this.isDebuggerAttached = false,
    this.hasHookingFramework = false,
    this.isTampered = false,
    this.isUnofficialStore = false,
    this.isVpnActive = false,
    this.hasProxyConfigured = false,
    this.isDevModeEnabled = false,
    this.isScreenCaptured = false,
    this.isMockLocation = false,
  });

  bool isRootedOrJailbroken;
  bool isEmulator;
  bool isDebuggerAttached;
  bool hasHookingFramework;
  bool isTampered;
  bool isUnofficialStore;
  bool isVpnActive;
  bool hasProxyConfigured;
  bool isDevModeEnabled;
  bool isScreenCaptured;
  bool isMockLocation;
}

@HostApi()
abstract class SecurityHostApi {
  @async
  NativeSecuritySignalsDto inspectSignals();

  bool enableSecureScreen();
  bool disableSecureScreen();
  bool isScreenCaptured();
}
