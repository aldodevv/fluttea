import 'package:fluttea/core/security/rasp/mock_security_provider.dart';
import 'package:fluttea/core/security/rasp/security_gate.dart';
import 'package:fluttea/core/security/rasp/security_policy.dart';
import 'package:fluttea/core/security/rasp/security_signals.dart';
import 'package:fluttea/core/security/rasp/security_verdict.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SecuritySignals', () {
    test('lists active threats correctly', () {
      const clean = SecuritySignals();
      expect(clean.hasAnyThreat, isFalse);
      expect(clean.activeThreats, isEmpty);

      const threatened = SecuritySignals(isRootedOrJailbroken: true, isDebuggerAttached: true);
      expect(threatened.hasAnyThreat, isTrue);
      expect(threatened.activeThreats.length, 2);
      expect(threatened.activeThreats, contains('Root / Jailbreak'));
      expect(threatened.activeThreats, contains('Debugger Attached'));
    });
  });

  group('SecurityPolicy', () {
    test('dev policy does not block on emulator or debugger', () {
      final policy = SecurityPolicy.dev();
      const devSignals = SecuritySignals(isEmulator: true, isDebuggerAttached: true);

      final verdict = policy.evaluate(devSignals);
      expect(verdict.isBlocked, isFalse);
    });

    test('prod policy blocks on root and wipes on tamper', () {
      final policy = SecurityPolicy.prod();

      final rootVerdict = policy.evaluate(const SecuritySignals(isRootedOrJailbroken: true));
      expect(rootVerdict, isA<SecurityVerdictBlock>());
      expect(rootVerdict.isBlocked, isTrue);

      final tamperVerdict = policy.evaluate(const SecuritySignals(isTampered: true));
      expect(tamperVerdict, isA<SecurityVerdictWipe>());
      expect(tamperVerdict.shouldWipe, isTrue);

      final proxyVerdict = policy.evaluate(const SecuritySignals(hasProxyConfigured: true));
      expect(proxyVerdict, isA<SecurityVerdictRestrict>());

      final cleanVerdict = policy.evaluate(const SecuritySignals());
      expect(cleanVerdict, isA<SecurityVerdictAllow>());
      expect(cleanVerdict.isAllowed, isTrue);
    });
  });

  group('SecurityGate', () {
    test('evaluates clean environment to allow', () async {
      final provider = MockSecurityProvider();
      final gate = SecurityGate(provider: provider, policy: SecurityPolicy.prod());

      final verdict = await gate.evaluate();
      expect(verdict.isAllowed, isTrue);
      expect(gate.latestVerdict, verdict);
      expect(gate.latestSignals?.hasAnyThreat, isFalse);
    });

    test('triggers wipe and block callbacks on critical threats', () async {
      var wiped = false;
      var blockedReasons = <String>[];

      final provider = MockSecurityProvider(signals: const SecuritySignals(isTampered: true));

      final gate = SecurityGate(
        provider: provider,
        policy: SecurityPolicy.prod(),
        onWipeSession: () async {
          wiped = true;
        },
        onBlocked: (reasons) async {
          blockedReasons = reasons;
        },
      );

      final verdict = await gate.evaluate();
      expect(verdict.shouldWipe, isTrue);
      expect(wiped, isTrue);
      expect(blockedReasons, isNotEmpty);
    });
  });
}
