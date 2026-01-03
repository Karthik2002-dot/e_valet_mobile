import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/operator_dashboard_kpis_response.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/operator_available_drivers_response.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/retrieval_requests_response.dart';

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
  final RetrievalRequestsResponse retrievalRequests;

  const OperatorDashboardLoaded({
    required this.kpis,
    required this.availableDrivers,
    required this.retrievalRequests,
  });

  List<Object> get props => [kpis, availableDrivers, retrievalRequests];
}

class OperatorDashboardError extends OperatorDashboardState {
  final String message;

  const OperatorDashboardError(this.message);

  List<Object> get props => [message];
}
