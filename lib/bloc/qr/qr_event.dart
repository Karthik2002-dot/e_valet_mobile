import 'package:equatable/equatable.dart';

abstract class QrEvent extends Equatable {
  const QrEvent();

  @override
  List<Object?> get props => [];
}

class QrCodeDetected extends QrEvent {
  final String code;

  const QrCodeDetected(this.code);

  @override
  List<Object?> get props => [code];
}

class QrResetRequested extends QrEvent {
  const QrResetRequested();
}

/// Tells the bloc that the Scan tab is visible and the camera may be started (e.g. after switching from Type ID Number tab).
class QrCameraActivateRequested extends QrEvent {
  const QrCameraActivateRequested();
}

/// Clear scanned data and turn camera back on so the user can scan again (stays on Scan tab).
class QrClearForRescan extends QrEvent {
  const QrClearForRescan();
}
