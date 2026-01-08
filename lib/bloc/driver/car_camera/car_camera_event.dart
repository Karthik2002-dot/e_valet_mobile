import 'package:equatable/equatable.dart';

abstract class CarCameraEvent extends Equatable {
  const CarCameraEvent();

  @override
  List<Object?> get props => [];
}

class ValidateImageRequested extends CarCameraEvent {
  final String imagePath;

  const ValidateImageRequested(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class ValidationReset extends CarCameraEvent {
  const ValidationReset();
}

class InitializeCameraRequested extends CarCameraEvent {
  const InitializeCameraRequested();
}

class ForceReinitializeCameraRequested extends CarCameraEvent {
  const ForceReinitializeCameraRequested();
}

class ToggleFlashRequested extends CarCameraEvent {
  const ToggleFlashRequested();
}
