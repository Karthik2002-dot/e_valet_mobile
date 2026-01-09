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
