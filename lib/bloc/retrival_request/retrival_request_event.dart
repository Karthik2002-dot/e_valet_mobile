import 'package:equatable/equatable.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';

abstract class RetrivalRequestEvent extends Equatable {
  const RetrivalRequestEvent();

  @override
  List<Object?> get props => [];
}

class FetchRetrivalRequests extends RetrivalRequestEvent {
  const FetchRetrivalRequests();
}

class AcceptRetrivalRequest extends RetrivalRequestEvent {
  final String sessionId;

  const AcceptRetrivalRequest(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class UpdateAssignedSessions extends RetrivalRequestEvent {
  final List<AssignedSession> sessions;

  const UpdateAssignedSessions(this.sessions);

  @override
  List<Object?> get props => [sessions];
}
