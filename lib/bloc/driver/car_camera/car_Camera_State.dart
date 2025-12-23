import 'package:equatable/equatable.dart';
import 'package:niloufer_valet_mobile/models/driver/image_validation/validation_result.dart';

abstract class CarCameraState extends Equatable {
  const CarCameraState();

  @override
  List<Object?> get props => [];
}

class CarCameraInitial extends CarCameraState {
  const CarCameraInitial();
}

class CarCameraValidating extends CarCameraState {
  const CarCameraValidating();
}

class CarCameraValidationSuccess extends CarCameraState {
  final ImageValidationResult result;
  final String imagePath;

  const CarCameraValidationSuccess({
    required this.result,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [result, imagePath];
}

class CarCameraValidationError extends CarCameraState {
  final String message;
  final ImageValidationResult result;

  const CarCameraValidationError({
    required this.message,
    required this.result,
  });

  @override
  List<Object?> get props => [message, result];
}
