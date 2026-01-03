abstract class OperatorDashboardEvent {
  const OperatorDashboardEvent();
}

class FetchDashboardKpis extends OperatorDashboardEvent {
  final String outletId;

  const FetchDashboardKpis({
    this.outletId = '2',
  });
}
