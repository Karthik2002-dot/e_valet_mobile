import 'package:equatable/equatable.dart';
import 'package:niloufer_valet_mobile/models/outlet/outlet.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginIdChanged extends LoginEvent {
  final String loginId;

  const LoginIdChanged(this.loginId);

  @override
  List<Object?> get props => [loginId];
}

class PinChanged extends LoginEvent {
  final String pin;

  const PinChanged(this.pin);

  @override
  List<Object?> get props => [pin];
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}

/// Fired when the user picks an outlet from the outlet selection dialog.
class OutletSelected extends LoginEvent {
  final Outlet outlet;

  const OutletSelected(this.outlet);

  @override
  List<Object?> get props => [outlet];
}

class LoginReset extends LoginEvent {
  const LoginReset();
}
