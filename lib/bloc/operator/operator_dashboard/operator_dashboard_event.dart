import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class OperatorDashboardEvent {
  const OperatorDashboardEvent();
}

class FetchDashboardKpis extends OperatorDashboardEvent {
  final String outletId;

  FetchDashboardKpis({
    String? outletId,
  }) : outletId = outletId ?? (dotenv.env['OUTLET_ID'] ?? '1');
}

/// Event for silently refreshing KPIs without showing loader
/// Used for real-time WebSocket updates
class RefreshDashboardKpisSilently extends OperatorDashboardEvent {
  final String outletId;
  final bool refreshKpis;
  final bool refreshDrivers;
  final bool refreshRequests;

  RefreshDashboardKpisSilently({
    String? outletId,
    this.refreshKpis = true,
    this.refreshDrivers = true,
    this.refreshRequests = true,
  }) : outletId = outletId ?? (dotenv.env['OUTLET_ID'] ?? '1');
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

class NewParkingEvent extends OperatorDashboardEvent {
  final String outletId;
  final bool refreshKpis;
  final bool refreshDrivers;
  final bool refreshRequests;

  NewParkingEvent({
    String? outletId,
    this.refreshKpis = true,
    this.refreshDrivers = true,
    this.refreshRequests = true,
  }) : outletId = outletId ?? (dotenv.env['OUTLET_ID'] ?? '1');
}
