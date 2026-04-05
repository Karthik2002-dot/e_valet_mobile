import 'package:equatable/equatable.dart';

abstract class PassAvailableDriversEvent extends Equatable {
  const PassAvailableDriversEvent();

  @override
  List<Object?> get props => [];
}

class FetchPassAvailableDrivers extends PassAvailableDriversEvent {
  final String sessionId;

  const FetchPassAvailableDrivers(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class PassSessionToDriver extends PassAvailableDriversEvent {
  final String sessionId;

  const PassSessionToDriver({
    required this.sessionId,
  });

  @override
  List<Object?> get props => [sessionId];
}
