import 'package:fluttea/core/network/handlers/session/session_workflow.dart';

class ForceLogoutWorkflow implements SessionWorkflow {
  const new({required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  Future<bool> onUnauthorized() async {
    await onLogout();
    return false;
  }

  @override
  Future<void> onExpired() async {
    await onLogout();
  }

  @override
  Future<void> onForceLogout() async {
    await onLogout();
  }
}
