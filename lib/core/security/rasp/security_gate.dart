import 'package:fluttea/core/security/rasp/security_policy.dart';
import 'package:fluttea/core/security/rasp/security_provider.dart';
import 'package:fluttea/core/security/rasp/security_signals.dart';
import 'package:fluttea/core/security/rasp/security_verdict.dart';

final class SecurityGate {
  new({
    required this._provider,
    this._policy = const SecurityPolicy(),
    this._onWipeSession,
    this._onBlocked,
  });

  final SecurityProvider _provider;
  final SecurityPolicy _policy;
  final Future<void> Function()? _onWipeSession;
  final Future<void> Function(List<String> reasons)? _onBlocked;

  SecuritySignals? _latestSignals;
  SecurityVerdict? _latestVerdict;

  SecuritySignals? get latestSignals => _latestSignals;
  SecurityVerdict? get latestVerdict => _latestVerdict;

  Future<SecurityVerdict> evaluate() async {
    final signals = await _provider.inspect();
    _latestSignals = signals;

    final verdict = _policy.evaluate(signals);
    _latestVerdict = verdict;

    if (verdict is SecurityVerdictWipe) {
      if (_onWipeSession != null) {
        await _onWipeSession();
      }
      if (_onBlocked != null) {
        await _onBlocked(verdict.reasons);
      }
    } else if (verdict is SecurityVerdictBlock) {
      if (_onBlocked != null) {
        await _onBlocked(verdict.reasons);
      }
    }

    return verdict;
  }
}
