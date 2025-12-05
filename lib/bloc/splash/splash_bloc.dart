import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(const SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
    on<SplashAnimationCompleted>(_onSplashAnimationCompleted);
  }

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());

    // Simulate loading time or any initialization
    await Future.delayed(const Duration(milliseconds: 500));

    emit(const SplashLoaded());
  }

  void _onSplashAnimationCompleted(
    SplashAnimationCompleted event,
    Emitter<SplashState> emit,
  ) {
    emit(const SplashCompleted());
  }
}
