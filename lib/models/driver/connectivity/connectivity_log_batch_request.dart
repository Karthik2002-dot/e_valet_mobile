/// One row for POST /connectivity/log/batch.
class ConnectivityLogEventItem {
  final String status;
  final String networkType;
  final String occurredAt;

  const ConnectivityLogEventItem({
    required this.status,
    required this.networkType,
    required this.occurredAt,
  });

  Map<String, dynamic> toJson() => {
        'status': status,
        'networkType': networkType,
        'occurredAt': occurredAt,
      };
}

/// Body for POST /connectivity/log/batch
class ConnectivityLogBatchRequest {
  final int outletId;
  final int shiftId;
  final List<ConnectivityLogEventItem> events;

  const ConnectivityLogBatchRequest({
    required this.outletId,
    required this.shiftId,
    required this.events,
  });

  Map<String, dynamic> toJson() => {
        'outletId': outletId,
        'shiftId': shiftId,
        'events': events.map((e) => e.toJson()).toList(),
      };
}
