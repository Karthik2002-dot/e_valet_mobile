import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/operator_dashboard_kpis_response.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_available_drivers_response.dart';

abstract class OperatorDashboardState {
  const OperatorDashboardState();
}

class OperatorDashboardInitial extends OperatorDashboardState {
  const OperatorDashboardInitial();
}

class OperatorDashboardLoading extends OperatorDashboardState {
  const OperatorDashboardLoading();
}

class OperatorDashboardLoaded extends OperatorDashboardState {
  final OperatorDashboardKpisResponse kpis;
  final OperatorAvailableDriversResponse availableDrivers;

  const OperatorDashboardLoaded({
    required this.kpis,
    required this.availableDrivers,
  });

  List<Object> get props => [kpis, availableDrivers];
}

class OperatorDashboardError extends OperatorDashboardState {
  final String message;

  const OperatorDashboardError(this.message);

  List<Object> get props => [message];
}
