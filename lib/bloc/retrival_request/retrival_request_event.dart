import 'package:equatable/equatable.dart';

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
