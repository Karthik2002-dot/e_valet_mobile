part of 'assigned_sessions_background_bloc.dart';

abstract class AssignedSessionsBackgroundEvent {
  const AssignedSessionsBackgroundEvent();
}

class StartAssignedSessionsPolling extends AssignedSessionsBackgroundEvent {
  const StartAssignedSessionsPolling();
}

class StopAssignedSessionsPolling extends AssignedSessionsBackgroundEvent {
  const StopAssignedSessionsPolling();
}

class RefreshAssignedSessions extends AssignedSessionsBackgroundEvent {
  const RefreshAssignedSessions();
}

class ReinitializeWebSocket extends AssignedSessionsBackgroundEvent {
  const ReinitializeWebSocket();
}

class _PollAssignedSessions extends AssignedSessionsBackgroundEvent {
  const _PollAssignedSessions();
}

/// Set sessions from pending API so the retrieval sheet (latest screen) shows first.
class SetSessionsFromPending extends AssignedSessionsBackgroundEvent {
  final List<dynamic> sessions;

  const SetSessionsFromPending(this.sessions);
}

/// Received when WebSocket emits retrieval:cancelled.
class RetrievalCancelledReceived extends AssignedSessionsBackgroundEvent {
  const RetrievalCancelledReceived();
}

/// Received when WebSocket emits retrieval:assigned with session data.
class SessionsReceivedFromSocket extends AssignedSessionsBackgroundEvent {
  final dynamic data;

  const SessionsReceivedFromSocket(this.data);
}
