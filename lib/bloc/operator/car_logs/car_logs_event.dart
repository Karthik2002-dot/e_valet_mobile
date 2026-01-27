abstract class CarLogsEvent {
  const CarLogsEvent();
}

class FetchCarLogs extends CarLogsEvent {
  final String outletId;

  const FetchCarLogs({
    required this.outletId,
  });
}
