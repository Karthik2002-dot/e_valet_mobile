import 'package:equatable/equatable.dart';

abstract class InitiateReparkEvent extends Equatable {
  const InitiateReparkEvent();

  @override
  List<Object?> get props => [];
}

class InitiateReparkRequested extends InitiateReparkEvent {
  final String sessionId;
  final double latitude;
  final double longitude;
  final double accuracy;

  const InitiateReparkRequested({
    required this.sessionId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  @override
  List<Object?> get props => [sessionId, latitude, longitude, accuracy];
}
