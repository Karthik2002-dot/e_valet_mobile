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
