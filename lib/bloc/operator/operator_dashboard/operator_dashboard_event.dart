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

  const RefreshDashboardKpisSilently({
    this.outletId = '2',
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
