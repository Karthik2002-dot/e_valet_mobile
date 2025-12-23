import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:niloufer_valet_mobile/bloc/driver/car_camera/car_camera_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/car_camera/car_Camera_State.dart';
import 'package:niloufer_valet_mobile/models/driver/image_validation/validation_result.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class CarCameraBloc extends Bloc<CarCameraEvent, CarCameraState> {
  CarCameraBloc() : super(const CarCameraInitial()) {
    on<ValidateImageRequested>(_onValidateImageRequested);
    on<ValidationReset>(_onValidationReset);
  }

  Future<void> _onValidateImageRequested(
    ValidateImageRequested event,
    Emitter<CarCameraState> emit,
  ) async {
    emit(const CarCameraValidating());

    try {
      final validationResult = await _validateImage(event.imagePath);

      if (validationResult.isValid) {
        emit(CarCameraValidationSuccess(
          result: validationResult,
          imagePath: event.imagePath,
        ));
      } else {
        emit(CarCameraValidationError(
          message: validationResult.errorMessage ??
              TextConstants.errorValidatingImage,
          result: validationResult,
        ));
      }
    } catch (e) {
      emit(CarCameraValidationError(
        message: '${TextConstants.errorValidatingImage}: ${e.toString()}',
        result: ImageValidationResult.failure(
          hasVehicle: false,
          hasNumberPlate: false,
          errorMessage: TextConstants.errorValidatingImage,
        ),
      ));
    }
  }

  void _onValidationReset(
    ValidationReset event,
    Emitter<CarCameraState> emit,
  ) {
    emit(const CarCameraInitial());
  }

  Future<ImageValidationResult> _validateImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);

      // Step 1: Check if image contains a vehicle using Image Labeling
      final hasVehicle = await _detectVehicle(inputImage);

      if (!hasVehicle) {
        return ImageValidationResult.failure(
          hasVehicle: false,
          hasNumberPlate: false,
          errorMessage: TextConstants.vehicleNotFound,
        );
      }

      // Step 2: Check if image contains text (number plate) using Text Recognition
      final textResult = await _detectNumberPlate(inputImage);

      if (!textResult.hasText) {
        return ImageValidationResult.failure(
          hasVehicle: true,
          hasNumberPlate: false,
          errorMessage: TextConstants.numberPlateNotFound,
        );
      }

      // Both vehicle and number plate detected
      return ImageValidationResult.success(
        detectedText: textResult.text,
      );
    } catch (e) {
      return ImageValidationResult.failure(
        hasVehicle: false,
        hasNumberPlate: false,
        errorMessage: '${TextConstants.errorProcessingImage}: ${e.toString()}',
      );
    }
  }

  Future<bool> _detectVehicle(InputImage inputImage) async {
    final imageLabeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.5),
    );

    try {
      final List<ImageLabel> labels =
          await imageLabeler.processImage(inputImage);

      // Check for vehicle-related labels
      final vehicleLabels = [
        'car',
        'vehicle',
        'automobile',
        'motor vehicle',
        'truck',
        'van',
        'suv',
        'sedan',
        'land vehicle',
        'transport',
      ];

      for (var label in labels) {
        final labelText = label.label.toLowerCase();
        for (var vehicleLabel in vehicleLabels) {
          if (labelText.contains(vehicleLabel) && label.confidence > 0.5) {
            await imageLabeler.close();
            return true;
          }
        }
      }

      await imageLabeler.close();
      return false;
    } catch (e) {
      await imageLabeler.close();
      return false;
    }
  }

  Future<({bool hasText, String? text})> _detectNumberPlate(
      InputImage inputImage) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      // Check if any text is detected
      if (recognizedText.text.isEmpty) {
        await textRecognizer.close();
        return (hasText: false, text: null);
      }

      // Look for patterns that resemble number plates
      // Number plates usually contain alphanumeric characters
      final hasAlphanumeric = RegExp(r'[A-Z0-9]{2,}').hasMatch(
        recognizedText.text.toUpperCase(),
      );

      await textRecognizer.close();

      if (hasAlphanumeric) {
        return (hasText: true, text: recognizedText.text);
      } else {
        return (hasText: false, text: null);
      }
    } catch (e) {
      await textRecognizer.close();
      return (hasText: false, text: null);
    }
  }
}
