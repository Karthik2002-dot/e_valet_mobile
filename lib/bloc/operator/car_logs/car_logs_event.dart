abstract class CarLogsEvent {
  const CarLogsEvent();
}

class FetchCarLogs extends CarLogsEvent {
  final String outletId;
  final int page;
  final int pageSize;

  const FetchCarLogs({
    required this.outletId,
    this.page = 1,
    this.pageSize = 10,
  });
}
