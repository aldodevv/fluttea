import 'package:fluttea/core/security/rasp/security_provider.dart';
import 'package:fluttea/core/security/rasp/security_signals.dart';

final class MockSecurityProvider implements SecurityProvider {
  new({this.signals = const SecuritySignals()});

  SecuritySignals signals;

  @override
  Future<SecuritySignals> inspect() async => signals;
}
