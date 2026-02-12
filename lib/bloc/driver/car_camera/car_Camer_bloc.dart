import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:niloufer_valet_mobile/bloc/driver/car_camera/car_camera_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/car_camera/car_Camera_State.dart';
import 'package:niloufer_valet_mobile/models/driver/image_validation/validation_result.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class CarCameraBloc extends Bloc<CarCameraEvent, CarCameraState> {
  CameraController? _cameraController;
  bool _isFlashOn = false;
  bool _isInitializing = false;

  CarCameraBloc() : super(const CarCameraInitial()) {
    on<ValidateImageRequested>(_onValidateImageRequested);
    on<ValidationReset>(_onValidationReset);
    on<InitializeCameraRequested>(_onInitializeCameraRequested);
    on<ForceReinitializeCameraRequested>(_onForceReinitializeCameraRequested);
    on<ToggleFlashRequested>(_onToggleFlashRequested);
  }

  Future<void> _onInitializeCameraRequested(
    InitializeCameraRequested event,
    Emitter<CarCameraState> emit,
  ) async {
    // Prevent multiple simultaneous initializations
    if (_isInitializing) return;

    // Check if we already have a valid camera controller
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      emit(CarCameraInitialized(
        cameraController: _cameraController!,
        isFlashOn: _isFlashOn,
      ));
      return;
    }

    await _performCameraInitialization(emit);
  }

  Future<void> _onForceReinitializeCameraRequested(
    ForceReinitializeCameraRequested event,
    Emitter<CarCameraState> emit,
  ) async {
    // Prevent multiple simultaneous initializations
    if (_isInitializing) return;

    // Always reinitialize, regardless of current state
    await _performCameraInitialization(emit);
  }

  Future<void> _performCameraInitialization(
      Emitter<CarCameraState> emit) async {
    _isInitializing = true;

    try {
      // Dispose existing camera controller if any
      await _cameraController?.dispose();
      _cameraController = null;

      // Reset flash state
      _isFlashOn = false;

      // Emit initial state to show loading
      emit(const CarCameraInitial());

      // Camera permission is requested on PermissionsScreen; only check here.
      final status = await Permission.camera.status;
      if (status == PermissionStatus.permanentlyDenied) {
        emit(const CarCameraInitializationError(
          message:
              'Camera permission is permanently denied. Please enable camera permission in app settings.',
        ));
        _isInitializing = false;
        return;
      }
      if (status != PermissionStatus.granted) {
        emit(const CarCameraInitializationError(
          message:
              'Camera permission is required. Please enable it in app settings.',
        ));
        _isInitializing = false;
        return;
      }

      // Add a small delay to ensure camera service is ready (especially after app restart)
      await Future.delayed(const Duration(milliseconds: 500));

      // Retry logic for availableCameras() - camera service might not be ready immediately
      List<CameraDescription> cameras = [];
      int retryCount = 0;
      const maxRetries = 3;
      const retryDelay = Duration(milliseconds: 800);
      bool camerasObtained = false;

      while (retryCount < maxRetries && !camerasObtained) {
        try {
          cameras = await availableCameras();
          if (cameras.isNotEmpty) {
            camerasObtained = true;
            break; // Success, exit retry loop
          }
          // If cameras list is empty, wait and retry
          if (retryCount < maxRetries - 1) {
            await Future.delayed(retryDelay);
          }
        } catch (e) {
          // If availableCameras() throws an error, wait and retry
          if (retryCount < maxRetries - 1) {
            await Future.delayed(retryDelay);
          } else {
            // Last retry failed, throw the error
            rethrow;
          }
        }
        retryCount++;
      }

      if (!camerasObtained || cameras.isEmpty) {
        emit(const CarCameraInitializationError(
          message: TextConstants.cameraNotAvailable,
        ));
        _isInitializing = false;
        return;
      }

      // Use the back camera
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Verify controller was created successfully
      if (_cameraController == null) {
        emit(const CarCameraInitializationError(
          message:
              '${TextConstants.errorInitializingCamera}: Failed to create camera controller',
        ));
        _isInitializing = false;
        return;
      }

      // Add timeout to camera initialization with retry logic
      bool initialized = false;
      int initRetryCount = 0;
      const maxInitRetries = 2;
      const initRetryDelay = Duration(milliseconds: 1000);

      while (!initialized && initRetryCount < maxInitRetries) {
        try {
          await _cameraController!.initialize().timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Camera initialization timed out');
            },
          );
          initialized = true;
        } catch (e) {
          if (initRetryCount < maxInitRetries - 1) {
            // Dispose and recreate controller before retry
            await _cameraController?.dispose();
            _cameraController = CameraController(
              camera,
              ResolutionPreset.medium,
              enableAudio: false,
              imageFormatGroup: ImageFormatGroup.jpeg,
            );
            await Future.delayed(initRetryDelay);
          } else {
            // Last retry failed, throw the error
            rethrow;
          }
          initRetryCount++;
        }
      }

      // Final null check before emitting success state
      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        emit(const CarCameraInitializationError(
          message:
              '${TextConstants.errorInitializingCamera}: Camera controller not properly initialized',
        ));
        _isInitializing = false;
        return;
      }

      emit(CarCameraInitialized(
        cameraController: _cameraController!,
        isFlashOn: _isFlashOn,
      ));
    } catch (e) {
      // Clean up on error
      await _cameraController?.dispose();
      _cameraController = null;

      // Extract error message, handling null check operator errors
      String errorMessage = e.toString();
      if (errorMessage.contains('Null check operator used on a null value')) {
        errorMessage =
            'Camera service is not ready yet. Please wait a moment and try again.';
      }

      emit(CarCameraInitializationError(
        message: '${TextConstants.errorInitializingCamera}: $errorMessage',
      ));
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _onToggleFlashRequested(
    ToggleFlashRequested event,
    Emitter<CarCameraState> emit,
  ) async {
    if (_cameraController == null) return;

    try {
      _isFlashOn = !_isFlashOn;

      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );

      emit(CarCameraFlashToggled(
        isFlashOn: _isFlashOn,
        cameraController: _cameraController!,
      ));
    } catch (e) {
      // If there's an error, revert the flash state
      _isFlashOn = !_isFlashOn;
      emit(CarCameraFlashToggled(
        isFlashOn: _isFlashOn,
        cameraController: _cameraController!,
      ));
    }
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
          cameraController: _cameraController!,
          isFlashOn: _isFlashOn,
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
        cameraController: _cameraController!,
        isFlashOn: _isFlashOn,
      ));
    }
  }

  void _onValidationReset(
    ValidationReset event,
    Emitter<CarCameraState> emit,
  ) {
    // Reset to initialized state to allow retaking photo
    if (_cameraController != null) {
      emit(CarCameraInitialized(
        cameraController: _cameraController!,
        isFlashOn: _isFlashOn,
      ));
    } else {
      emit(const CarCameraInitial());
    }
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

  void dispose() {
    _cameraController?.dispose();
  }
}
