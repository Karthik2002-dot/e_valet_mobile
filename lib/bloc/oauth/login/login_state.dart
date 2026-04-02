import 'package:equatable/equatable.dart';
import 'package:niloufer_valet_mobile/models/oauth/profile.dart';
import 'package:niloufer_valet_mobile/models/outlet/outlet.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

/// Login API succeeded; now waiting for the user to select an outlet.
/// Emitted for ALL roles (driver, operator, scanner).
class LoginSuccessNeedsOutletSelection extends LoginState {
  final Profile profile;
  final List<Outlet> outlets;
  final bool isDriver;
  final bool isOperator;
  final bool isScanner;

  const LoginSuccessNeedsOutletSelection({
    required this.profile,
    required this.outlets,
    required this.isDriver,
    required this.isOperator,
    required this.isScanner,
  });

  @override
  List<Object?> get props => [profile, outlets, isDriver, isOperator, isScanner];
}

/// Outlet selected; now performing clock-in / verify-location in the background.
class LoginOutletSelectionLoading extends LoginState {
  const LoginOutletSelectionLoading();
}

class LoginSuccess extends LoginState {
  final Profile profile;

  const LoginSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Driver logged in but clock-in failed because they are too far from the outlet.
class LoginSuccessClockInTooFar extends LoginState {
  final Profile profile;
  final String message;

  const LoginSuccessClockInTooFar({
    required this.profile,
    required this.message,
  });

  @override
  List<Object?> get props => [profile, message];
}

/// Operator/Scanner logged in but verify-location returned withinBounds: false.
class LoginSuccessLocationTooFar extends LoginState {
  final Profile profile;
  final String outletName;
  final double distanceMeters;
  final double allowedRadiusMeters;

  const LoginSuccessLocationTooFar({
    required this.profile,
    required this.outletName,
    required this.distanceMeters,
    required this.allowedRadiusMeters,
  });

  @override
  List<Object?> get props =>
      [profile, outletName, distanceMeters, allowedRadiusMeters];
}

class LoginFailure extends LoginState {
  final String message;

  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}
