import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/operator_dashboard_kpis_response.dart';

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

  const OperatorDashboardLoaded(this.kpis);

  List<Object> get props => [kpis];
}

class OperatorDashboardError extends OperatorDashboardState {
  final String message;

  const OperatorDashboardError(this.message);

  List<Object> get props => [message];
}
