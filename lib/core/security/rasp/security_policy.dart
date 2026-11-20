import 'package:fluttea/core/security/rasp/security_signals.dart';
import 'package:fluttea/core/security/rasp/security_verdict.dart';

final class SecurityPolicy {
  const new({
    this.blockOnRoot = true,
    this.blockOnTamper = true,
    this.blockOnHooking = true,
    this.blockOnDebugger = true,
    this.blockOnEmulator = false,
    this.restrictOnVpn = false,
    this.restrictOnProxy = true,
    this.wipeOnTamper = false,
    this.warnOnDevMode = true,
  });

  factory dev() {
    return const SecurityPolicy(
      blockOnRoot: false,
      blockOnTamper: false,
      blockOnHooking: false,
      blockOnDebugger: false,
      restrictOnProxy: false,
      warnOnDevMode: false,
    );
  }

  factory prod() {
    return const SecurityPolicy(blockOnEmulator: true, wipeOnTamper: true);
  }

  final bool blockOnRoot;
  final bool blockOnTamper;
  final bool blockOnHooking;
  final bool blockOnDebugger;
  final bool blockOnEmulator;
  final bool restrictOnVpn;
  final bool restrictOnProxy;
  final bool wipeOnTamper;
  final bool warnOnDevMode;

  SecurityVerdict evaluate(SecuritySignals signals) {
    final wipeReasons = <String>[];
    final blockReasons = <String>[];
    final restrictReasons = <String>[];
    final warnReasons = <String>[];

    if (signals.isTampered) {
      if (wipeOnTamper) {
        wipeReasons.add('Binary integrity compromise detected (tampered)');
      } else if (blockOnTamper) {
        blockReasons.add('Binary integrity compromise detected (tampered)');
      }
    }

    if (signals.isRootedOrJailbroken) {
      if (blockOnRoot) {
        blockReasons.add('Privileged environment detected (root/jailbreak)');
      } else {
        warnReasons.add('Device is rooted/jailbroken');
      }
    }

    if (signals.hasHookingFramework) {
      if (blockOnHooking) {
        blockReasons.add('Dynamic instrumentation/hooking detected');
      } else {
        warnReasons.add('Hooking framework present');
      }
    }

    if (signals.isDebuggerAttached) {
      if (blockOnDebugger) {
        blockReasons.add('Active debugger attached to process');
      } else {
        warnReasons.add('Debugger attached');
      }
    }

    if (signals.isEmulator) {
      if (blockOnEmulator) {
        blockReasons.add('Running inside virtualized emulator/simulator');
      } else {
        warnReasons.add('Emulator environment');
      }
    }

    if (signals.hasProxyConfigured) {
      if (restrictOnProxy) {
        restrictReasons.add('Active network proxy configured');
      } else {
        warnReasons.add('Proxy configured');
      }
    }

    if (signals.isVpnActive && restrictOnVpn) {
      restrictReasons.add('Active VPN connection');
    }

    if (signals.isDevModeEnabled && warnOnDevMode) {
      warnReasons.add('Developer options enabled');
    }

    if (wipeReasons.isNotEmpty) {
      return SecurityVerdict.wipe(wipeReasons);
    }
    if (blockReasons.isNotEmpty) {
      return SecurityVerdict.block(blockReasons);
    }
    if (restrictReasons.isNotEmpty) {
      return SecurityVerdict.restrict(restrictReasons);
    }
    if (warnReasons.isNotEmpty) {
      return SecurityVerdict.warn(warnReasons);
    }

    return const SecurityVerdict.allow();
  }
}
