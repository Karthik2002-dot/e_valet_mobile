abstract class CarLogsEvent {
  const CarLogsEvent();
}

class FetchCarLogs extends CarLogsEvent {
  final String outletId;
  final int page;
  final int pageSize;
  final String? search;

  const FetchCarLogs({
    required this.outletId,
    this.page = 1,
    this.pageSize = 10,
    this.search,
  });
}

class UpdateCarLogStatus extends CarLogsEvent {
  final String sessionId;
  final String newStatus;

  const UpdateCarLogStatus({
    required this.sessionId,
    required this.newStatus,
  });
}
