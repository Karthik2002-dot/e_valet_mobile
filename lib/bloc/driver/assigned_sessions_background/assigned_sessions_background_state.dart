part of 'assigned_sessions_background_bloc.dart';

abstract class AssignedSessionsBackgroundState {
  const AssignedSessionsBackgroundState();
}

class AssignedSessionsBackgroundInitial
    extends AssignedSessionsBackgroundState {
  const AssignedSessionsBackgroundInitial();
}

class AssignedSessionsCancelled extends AssignedSessionsBackgroundState {
  const AssignedSessionsCancelled();
}

class AssignedSessionsBackgroundData extends AssignedSessionsBackgroundState {
  final List<dynamic> sessions;

  const AssignedSessionsBackgroundData(this.sessions);

  bool get hasSessions => sessions.isNotEmpty;
}
