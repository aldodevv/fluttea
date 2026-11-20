final class SecuritySignals {
  const new({
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
    this.customSignals = const <String, dynamic>{},
  });

  final bool isRootedOrJailbroken;
  final bool isEmulator;
  final bool isDebuggerAttached;
  final bool hasHookingFramework;
  final bool isTampered;
  final bool isUnofficialStore;
  final bool isVpnActive;
  final bool hasProxyConfigured;
  final bool isDevModeEnabled;
  final bool isScreenCaptured;
  final bool isMockLocation;
  final Map<String, dynamic> customSignals;

  List<String> get activeThreats {
    final threats = <String>[];
    if (isRootedOrJailbroken) threats.add('Root / Jailbreak');
    if (isEmulator) threats.add('Emulator / Simulator');
    if (isDebuggerAttached) threats.add('Debugger Attached');
    if (hasHookingFramework) threats.add('Hooking Framework (Frida/Xposed)');
    if (isTampered) threats.add('Application Tampered');
    if (isUnofficialStore) threats.add('Unofficial Store');
    if (isVpnActive) threats.add('VPN Active');
    if (hasProxyConfigured) threats.add('Proxy Configured');
    if (isDevModeEnabled) threats.add('Developer Options Enabled');
    if (isScreenCaptured) threats.add('Screen Captured');
    if (isMockLocation) threats.add('Mock Location');
    return List<String>.unmodifiable(threats);
  }

  bool get hasAnyThreat => activeThreats.isNotEmpty;

  Map<String, dynamic> toMap() => {
    'isRootedOrJailbroken': isRootedOrJailbroken,
    'isEmulator': isEmulator,
    'isDebuggerAttached': isDebuggerAttached,
    'hasHookingFramework': hasHookingFramework,
    'isTampered': isTampered,
    'isUnofficialStore': isUnofficialStore,
    'isVpnActive': isVpnActive,
    'hasProxyConfigured': hasProxyConfigured,
    'isDevModeEnabled': isDevModeEnabled,
    'isScreenCaptured': isScreenCaptured,
    'isMockLocation': isMockLocation,
    ...customSignals,
  };
}
