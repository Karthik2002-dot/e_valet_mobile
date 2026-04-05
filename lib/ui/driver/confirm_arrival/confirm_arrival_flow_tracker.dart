class ConfirmArrivalFlowTracker {
  ConfirmArrivalFlowTracker._();

  static String? _activeSessionId;

  static String? get activeSessionId => _activeSessionId;

  static void setActiveSession(String? sessionId) {
    final id = sessionId?.trim() ?? '';
    _activeSessionId = id.isEmpty ? null : id;
  }

  static void clearIfMatches(String? sessionId) {
    final id = sessionId?.trim() ?? '';
    if (id.isEmpty) return;
    if ((_activeSessionId ?? '').trim() == id) {
      _activeSessionId = null;
    }
  }
}
