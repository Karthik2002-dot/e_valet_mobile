import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:lottie/lottie.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text_field.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/driver/car_Camera/car_Camer_widgets/camera_preview_widget.dart';
import 'package:niloufer_valet_mobile/ui/driver/car_Camera/car_Camer_widgets/camera_top_overlay.dart';
import 'package:niloufer_valet_mobile/ui/driver/preview_car/preview_Car_Screen.dart';
import 'package:niloufer_valet_mobile/bloc/driver/car_camera/car_Camer_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/car_camera/car_camera_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/car_camera/car_Camera_State.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/status/tab_chip.dart';

/// Third screen: Vehicle details + Location/Vehicle Number | Car Photo tabs.
/// - [cameViaTagNumber] true (tag flow): default tab is Parking Number (location + vehicle number form).
/// - [cameViaTagNumber] false (QR flow): default tab is Scan — Lottie (Carphoto.json) 2 sec then camera in same area.
/// - Scan tab: Carphoto.json 2 sec → camera → Capture → validate → Preview screen → user taps Submit → Park/Repark API → Car Success.
/// - Parking Number tab: enter parking location + vehicle number → Submit → Preview screen → user taps Submit → Park/Repark API → Car Success.
/// When [sessionId] is provided (e.g. from pending session / card), it is saved so submit uses it; [isReparking] is passed to the Park API.
class CarPhotoIntroScreen extends StatefulWidget {
  final bool cameViaTagNumber;
  final VoidCallback? onReturnFromCamera;

  /// When opening from a pending session (e.g. CHECKED_IN card), pass sessionId so the screen can submit without scanning first.
  final String? sessionId;

  /// True when continuing a reparking flow (pending REPARKING).
  final bool isReparking;

  const CarPhotoIntroScreen({
    super.key,
    required this.cameViaTagNumber,
    this.onReturnFromCamera,
    this.sessionId,
    this.isReparking = false,
  });

  @override
  State<CarPhotoIntroScreen> createState() => _CarPhotoIntroScreenState();
}

class _CarPhotoIntroScreenState extends State<CarPhotoIntroScreen> {
  final TextEditingController _parkingLocationController =
      TextEditingController();
  final TextEditingController _vehicleNumberController =
      TextEditingController();
  final FocusNode _parkingLocationFocusNode = FocusNode();
  final FocusNode _vehicleNumberFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  /// 0 = Parking Number (default, no camera), 1 = Scan (Lottie then camera)
  int _selectedTab = 0;

  /// 0 = Lottie (2 sec), 1 = camera in same area (only when on Scan tab)
  int _scanPhase = 0;
  Timer? _lottieTimer;
  late CarCameraBloc _cameraBloc;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _cameraBloc = CarCameraBloc();
    if (widget.cameViaTagNumber) {
      _selectedTab =
          0; // Tag flow: show Parking Number (location + vehicle) first
    } else {
      _selectedTab = 1; // QR flow: go straight to Scan (Lottie then camera)
      _scanPhase = 0;
      _startLottieTimer();
    }
    if (widget.sessionId != null && widget.sessionId!.isNotEmpty) {
      TokenStorage.saveSessionId(widget.sessionId!).catchError((e) {
        debugPrint('[CarPhotoIntro] Failed to save sessionId: $e');
      });
    }
  }

  void _startLottieTimer() {
    _lottieTimer?.cancel();
    _lottieTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      _lottieTimer = null;
      setState(() {
        _scanPhase = 1;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _cameraBloc.add(const InitializeCameraRequested());
      });
    });
  }

  void _onSelectParkingNumberTab() {
    _lottieTimer?.cancel();
    _cameraBloc.add(const DisposeCameraRequested());
    setState(() => _selectedTab = 0);
  }

  void _onSelectScanTab() {
    if (_selectedTab == 1) return;
    setState(() {
      _selectedTab = 1;
      _scanPhase = 0;
    });
    _startLottieTimer();
  }

  /// Navigate to preview screen so user can confirm and submit from there (Park/Repark API runs on preview submit).
  Future<void> _navigateToPreview(
    BuildContext context, {
    String? imagePath,
    String? parkingLocation,
    String? vehicleNumber,
  }) async {
    debugPrint(
        '[CarPhotoIntro] _navigateToPreview: imagePath=$imagePath, parkingLocation=$parkingLocation, vehicleNumber=$vehicleNumber');
    if (!mounted) return;
    try {
      final sessionId = await TokenStorage.getSessionId();
      if (!mounted) return;
      if (sessionId == null || sessionId.isEmpty) {
        SnackBars.showErrorSnackBar(
          context,
          'No active session. Please scan or enter badge number first.',
        );
        return;
      }
      if (!mounted) return;
      final isFromScan = imagePath != null && imagePath.isNotEmpty;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PreviewCarScreen(
            imagePath: imagePath,
            sessionId: sessionId,
            isReparking: widget.isReparking,
            parkingLocation: parkingLocation,
            vehicleNumber: vehicleNumber,
          ),
        ),
      );
      // When user returns from preview (e.g. Retake), reset camera so it shows again.
      if (mounted && isFromScan && _selectedTab == 1) {
        _cameraBloc.add(const ValidationReset());
      }
    } catch (e) {
      debugPrint('[CarPhotoIntro] _navigateToPreview error: $e');
      if (mounted) {
        SnackBars.showErrorSnackBar(
          context,
          'Unable to open preview. Please try again.',
        );
      }
    }
  }

  void _onCapturePhoto(BuildContext ctx) async {
    final state = ctx.read<CarCameraBloc>().state;
    if (state is! CarCameraInitialized &&
        state is! CarCameraFlashToggled &&
        state is! CarCameraValidationError) {
      SnackBars.showErrorSnackBar(ctx, TextConstants.cameraNotReady);
      return;
    }
    if (_isCapturing) return;
    try {
      _isCapturing = true;
      final cameraController = state is CarCameraInitialized
          ? state.cameraController
          : state is CarCameraFlashToggled
              ? state.cameraController
              : (state as CarCameraValidationError).cameraController;
      final isFlashOn = state is CarCameraInitialized
          ? state.isFlashOn
          : state is CarCameraFlashToggled
              ? state.isFlashOn
              : (state as CarCameraValidationError).isFlashOn;
      if (!cameraController.value.isInitialized) {
        SnackBars.showErrorSnackBar(ctx, TextConstants.cameraNotReady);
        return;
      }
      await cameraController.setFlashMode(
        isFlashOn ? FlashMode.always : FlashMode.off,
      );
      final image = await cameraController.takePicture();
      if (cameraController.value.isInitialized) {
        await cameraController.setFlashMode(
          isFlashOn ? FlashMode.torch : FlashMode.off,
        );
      }
      ctx.read<CarCameraBloc>().add(const ValidationReset());
      if (mounted) {
        ctx.read<CarCameraBloc>().add(ValidateImageRequested(image.path));
      }
    } catch (e) {
      if (mounted) {
        SnackBars.showErrorSnackBar(
          ctx,
          '${TextConstants.errorCapturingPhoto}: $e',
        );
      }
    } finally {
      if (mounted) _isCapturing = false;
    }
  }

  /// Navigate to preview screen with parking location and vehicle number; API is called when user submits from preview.
  void _onSubmitParkingLocation(BuildContext ctx) {
    debugPrint('[CarPhotoIntro] _onSubmitParkingLocation called');
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final location = _parkingLocationController.text.trim();
    final vehicleNumber = _vehicleNumberController.text.trim();
    if (location.isEmpty) {
      SnackBars.showErrorSnackBar(
          ctx, TextConstants.pleaseEnterParkingLocation);
      return;
    }
    if (vehicleNumber.isEmpty) {
      SnackBars.showErrorSnackBar(ctx, TextConstants.pleaseEnterVehicleNumber);
      return;
    }
    _navigateToPreview(ctx,
        parkingLocation: location, vehicleNumber: vehicleNumber);
  }

  @override
  void dispose() {
    _lottieTimer?.cancel();
    _parkingLocationController.dispose();
    _vehicleNumberController.dispose();
    _parkingLocationFocusNode.dispose();
    _vehicleNumberFocusNode.dispose();
    _cameraBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return BlocProvider<CarCameraBloc>.value(
      value: _cameraBloc,
      child: BlocListener<CarCameraBloc, CarCameraState>(
        listener: (context, state) {
          if (state is CarCameraValidationSuccess) {
            _navigateToPreview(context, imagePath: state.imagePath);
          } else if (state is CarCameraValidationError) {
            SnackBars.showErrorSnackBar(context, state.message);
            context.read<CarCameraBloc>().add(const ValidationReset());
          }
        },
        child: Builder(
          builder: (bodyContext) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop && mounted) {
                  SnackBars.showErrorSnackBar(
                    context,
                    TextConstants.pleaseCompleteParkingProcess,
                  );
                }
              },
              child: Scaffold(
                backgroundColor: AppColors.lightBeigeBackground,
                appBar: const CustomAppBar(),
                body: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: h * 0.016),
                      _buildHeaderAboveTabs(w, h),
                      SizedBox(height: h * 0.016),
                      _buildTabs(w),
                      Expanded(
                        child: _selectedTab == 0
                            ? _buildTypeParkingNumberContent(w, h, bodyContext)
                            : _buildScanTabContent(w, h),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Same style as driver_qr_scanner_content: title + "what to do" hint above the tabs.
  Widget _buildHeaderAboveTabs(double w, double h) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: h * 0.012,
        horizontal: w * 0.04,
      ),
      color: AppColors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextComponent(
            labelText: TextConstants.vehicleDetailsTitle,
            fontSize: w * 0.045,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
          SizedBox(height: h * 0.006),
          Text(
            TextConstants.vehicleDetailsParkingPhotoHint,
            style: TextStyle(
              fontSize: w * 0.032,
              color: AppColors.black,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(double w) {
    final isParkingNumber = _selectedTab == 0;
    final isScan = _selectedTab == 1;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.02),
      child: Row(
        children: [
          Expanded(
            child: TabChip(
              icon: Icons.dialpad,
              label: TextConstants.locationVehicleNumber,
              isActive: isParkingNumber,
              onTap: isParkingNumber ? null : _onSelectParkingNumberTab,
            ),
          ),
          SizedBox(width: w * 0.025),
          Expanded(
            child: TabChip(
              icon: Icons.qr_code_scanner,
              label: TextConstants.carPhoto,
              isActive: isScan,
              onTap: isScan ? null : _onSelectScanTab,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanTabContent(double w, double h) {
    final padding = w * 0.02;
    if (_scanPhase == 0) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(w * 0.04),
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(w * 0.04),
                      border: Border.all(color: AppColors.white, width: 2.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Lottie.asset(
                      'assets/jsons/Carphoto.json',
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: h * 0.018,
                child: Container(
                  width: w * 0.2,
                  height: w * 0.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.actionButtonYellow,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Phase 1: camera in same area (same layout as old camera: preview + flash + capture)
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(w * 0.04),
        ),
        clipBehavior: Clip.antiAlias,
        child: BlocBuilder<CarCameraBloc, CarCameraState>(
          builder: (context, state) {
            final isReady = state is CarCameraInitialized ||
                state is CarCameraFlashToggled ||
                state is CarCameraValidationError;
            final controller = state is CarCameraInitialized
                ? state.cameraController
                : state is CarCameraFlashToggled
                    ? state.cameraController
                    : state is CarCameraValidationError
                        ? state.cameraController
                        : null;
            final isFlashOn = state is CarCameraInitialized
                ? state.isFlashOn
                : state is CarCameraFlashToggled
                    ? state.isFlashOn
                    : state is CarCameraValidationError
                        ? state.isFlashOn
                        : false;
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.white, width: 2.5),
                      borderRadius: BorderRadius.circular(w * 0.04),
                    ),
                    child: CameraPreviewWidget(
                      isCameraInitialized: isReady && controller != null,
                      cameraController: controller,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: CameraTopOverlay(
                    isFlashOn: isFlashOn,
                    onFlashToggle: () => context
                        .read<CarCameraBloc>()
                        .add(const ToggleFlashRequested()),
                    topOffset: 0,
                  ),
                ),
                Positioned(
                  bottom: h * 0.018,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (_isCapturing) return;
                        final s = context.read<CarCameraBloc>().state;
                        if (s is CarCameraInitialized ||
                            s is CarCameraFlashToggled ||
                            s is CarCameraValidationError) {
                          _onCapturePhoto(context);
                        }
                      },
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: w * 0.2,
                        height: w * 0.2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.actionButtonYellow,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTypeParkingNumberContent(
      double w, double h, BuildContext blocContext) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: w * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: h * 0.02),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(w * 0.025),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(w * 0.03),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow10,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextComponent(
                    labelText: TextConstants.parkingLocationLabel,
                    fontSize: w * 0.035,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                  TextFieldComponent(
                    labelText: TextConstants.emptyText,
                    hintText: TextConstants.parkingLocationHint,
                    controller: _parkingLocationController,
                    focusNode: _parkingLocationFocusNode,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    onSubmitEditing: () {
                      FocusScope.of(blocContext)
                          .requestFocus(_vehicleNumberFocusNode);
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return TextConstants.pleaseEnterParkingLocation;
                      }
                      return null;
                    },
                    borderRadius: w * 0.03,
                  ),
                  SizedBox(height: h * 0.04),
                  TextComponent(
                    labelText: TextConstants.vehicleNumberLabel,
                    fontSize: w * 0.035,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                  TextFieldComponent(
                    labelText: TextConstants.emptyText,
                    hintText: TextConstants.vehicleNumberHint,
                    controller: _vehicleNumberController,
                    focusNode: _vehicleNumberFocusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    textInputAction: TextInputAction.done,
                    onSubmitEditing: () =>
                        _onSubmitParkingLocation(blocContext),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return TextConstants.pleaseEnterVehicleNumber;
                      }
                      return null;
                    },
                    borderRadius: w * 0.03,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: h * 0.025),
          SizedBox(
            width: double.infinity,
            height: h * 0.062,
            child: ElevatedButton(
              onPressed: () => _onSubmitParkingLocation(blocContext),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.actionButtonYellow,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(w * 0.025),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextComponent(
                    labelText: TextConstants.submitButton,
                    fontSize: w * 0.045,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                  SizedBox(width: w * 0.02),
                  Icon(
                    Icons.arrow_forward,
                    color: AppColors.white,
                    size: w * 0.05,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: h * 0.02),
        ],
      ),
    );
  }
}
