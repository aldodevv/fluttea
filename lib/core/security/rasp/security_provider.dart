import 'package:fluttea/core/security/rasp/security_signals.dart';

abstract interface class SecurityProvider {
  Future<SecuritySignals> inspect();
}
