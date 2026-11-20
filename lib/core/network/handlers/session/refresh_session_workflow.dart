import 'package:fluttea/core/network/handlers/session/session_workflow.dart';

class RefreshSessionWorkflow implements SessionWorkflow {
  const new({required this.refreshToken, required this.onSessionExpired});

  final Future<bool> Function() refreshToken;
  final Future<void> Function() onSessionExpired;

  @override
  Future<bool> onUnauthorized() async {
    final success = await refreshToken();
    if (!success) {
      await onExpired();
    }
    return success;
  }

  @override
  Future<void> onExpired() async {
    await onSessionExpired();
  }

  @override
  Future<void> onForceLogout() async {
    await onSessionExpired();
  }
}
