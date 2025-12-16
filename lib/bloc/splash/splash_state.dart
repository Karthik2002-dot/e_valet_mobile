import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashLoading extends SplashState {
  const SplashLoading();
}

class SplashLoaded extends SplashState {
  const SplashLoaded();
}

class SplashCompleted extends SplashState {
  final bool isAuthenticated;

  const SplashCompleted({this.isAuthenticated = false});

  @override
  List<Object?> get props => [isAuthenticated];
}

class SplashError extends SplashState {
  final String message;

  const SplashError(this.message);

  @override
  List<Object?> get props => [message];
}
