import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/car_logs_response.dart';

abstract class CarLogsState {
  const CarLogsState();
}

class CarLogsInitial extends CarLogsState {
  const CarLogsInitial();
}

class CarLogsLoading extends CarLogsState {
  const CarLogsLoading();
}

class CarLogsLoaded extends CarLogsState {
  final CarLogsResponse carLogsResponse;

  const CarLogsLoaded({required this.carLogsResponse});

  List<Object> get props => [carLogsResponse];
}

class CarLogsError extends CarLogsState {
  final String message;

  const CarLogsError(this.message);

  List<Object> get props => [message];
}
