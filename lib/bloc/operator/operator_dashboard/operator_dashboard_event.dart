abstract class OperatorDashboardEvent {
  const OperatorDashboardEvent();
}

class FetchDashboardKpis extends OperatorDashboardEvent {
  final String outletId;

  const FetchDashboardKpis({
    this.outletId = '2',
  });
}

/// Event for silently refreshing KPIs without showing loader
/// Used for real-time WebSocket updates
class RefreshDashboardKpisSilently extends OperatorDashboardEvent {
  final String outletId;
  final bool refreshKpis;
  final bool refreshDrivers;
  final bool refreshRequests;

  const RefreshDashboardKpisSilently({
    this.outletId = '2',
    this.refreshKpis = true,
    this.refreshDrivers = true,
    this.refreshRequests = true,
  });
}

class AssignDriverToRetrieval extends OperatorDashboardEvent {
  final String driverUserId;
  final String sessionId;

  const AssignDriverToRetrieval({
    required this.driverUserId,
    required this.sessionId,
  });
}

class CreateManualRetrievalRequest extends OperatorDashboardEvent {
  final int cardNumber;
  final String outletId;

  const CreateManualRetrievalRequest({
    required this.cardNumber,
    required this.outletId,
  });
}
