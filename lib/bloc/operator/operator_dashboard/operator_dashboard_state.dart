import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/operator_dashboard_kpis_response.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/operator_available_drivers_response.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/retrieval_requests_response.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/digital_key_rack_response.dart';
import 'package:niloufer_valet_mobile/models/operator/operator_dashboard/assign_retrieval_response.dart';

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
  final DigitalKeyRackResponse digitalKeyRack;

  const OperatorDashboardLoaded({
    required this.kpis,
    required this.availableDrivers,
    required this.retrievalRequests,
    required this.digitalKeyRack,
  });

  List<Object> get props =>
      [kpis, availableDrivers, retrievalRequests, digitalKeyRack];
}

class OperatorDashboardError extends OperatorDashboardState {
  final String message;

  const OperatorDashboardError(this.message);

  List<Object> get props => [message];
}

class AssignmentInProgress extends OperatorDashboardState {
  const AssignmentInProgress();
}

class AssignmentSuccess extends OperatorDashboardState {
  final AssignRetrievalResponse response;

  const AssignmentSuccess(this.response);

  List<Object> get props => [response];
}

class AssignmentError extends OperatorDashboardState {
  final String message;

  const AssignmentError(this.message);

  List<Object> get props => [message];
}
