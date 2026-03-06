import 'package:equatable/equatable.dart';

abstract class OperatorOvertimeEvent extends Equatable {
  const OperatorOvertimeEvent();

  @override
  List<Object?> get props => [];
}

/// Load valets for the overtime screen.
class OvertimeLoadValets extends OperatorOvertimeEvent {
  final String outletId;

  const OvertimeLoadValets({required this.outletId});

  @override
  List<Object?> get props => [outletId];
}

/// Grant overtime for a driver (after user confirms in dialog).
class OvertimeGrantRequested extends OperatorOvertimeEvent {
  final String driverUserId;
  final int outletId;
  final int extraMinutes;

  const OvertimeGrantRequested({
    required this.driverUserId,
    required this.outletId,
    required this.extraMinutes,
  });

  @override
  List<Object?> get props => [driverUserId, outletId, extraMinutes];
}
