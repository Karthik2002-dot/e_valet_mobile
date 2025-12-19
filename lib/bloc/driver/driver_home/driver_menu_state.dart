import 'package:equatable/equatable.dart';
import 'package:niloufer_valet_mobile/models/oauth/logout_response.dart';

abstract class DriverMenuState extends Equatable {
  const DriverMenuState();

  @override
  List<Object?> get props => [];
}

class DriverMenuInitial extends DriverMenuState {
  const DriverMenuInitial();
}

enum DriverMenuActionType { logout, profile }

class DriverMenuAction extends DriverMenuState {
  final DriverMenuActionType action;

  const DriverMenuAction(this.action);

  @override
  List<Object?> get props => [action];
}

class DriverMenuLogoutLoading extends DriverMenuState {
  const DriverMenuLogoutLoading();
}

class DriverMenuLogoutSuccess extends DriverMenuState {
  final LogoutResponse response;

  const DriverMenuLogoutSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class DriverMenuLogoutFailure extends DriverMenuState {
  final String message;

  const DriverMenuLogoutFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class DriverHomeLoaded extends DriverMenuState {
  final String driverName;
  final bool isOnBreak;
  final bool isOnline;

  const DriverHomeLoaded({
    required this.driverName,
    required this.isOnBreak,
    required this.isOnline,
  });

  DriverHomeLoaded copyWith({
    String? driverName,
    bool? isOnBreak,
    bool? isOnline,
  }) {
    return DriverHomeLoaded(
      driverName: driverName ?? this.driverName,
      isOnBreak: isOnBreak ?? this.isOnBreak,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  List<Object?> get props => [
        driverName,
        isOnBreak,
        isOnline,
      ];
}
