abstract interface class SessionWorkflow {
  Future<bool> onUnauthorized();

  Future<void> onExpired();

  Future<void> onForceLogout();
}
