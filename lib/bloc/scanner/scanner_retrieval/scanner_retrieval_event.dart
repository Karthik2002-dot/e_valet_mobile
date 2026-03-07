import 'package:equatable/equatable.dart';

abstract class ScannerRetrievalEvent extends Equatable {
  const ScannerRetrievalEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches retrieval requests for the outlet (outletId from env).
class ScannerRetrievalFetchRequested extends ScannerRetrievalEvent {
  const ScannerRetrievalFetchRequested();
}

/// Refreshes retrieval requests silently (no loading state). Used when WebSocket
/// emits session:status_changed so the list updates in real time.
class ScannerRetrievalRefreshSilently extends ScannerRetrievalEvent {
  const ScannerRetrievalRefreshSilently();
}
