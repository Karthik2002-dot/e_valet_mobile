import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class CameraBottomOverlay extends StatefulWidget {
  final Function(BuildContext) onCapture;
  final Future<void> Function(BuildContext, String)? onSubmit;
  final bool positionAtTop;
  /// Pre-fill parking location (e.g. from third screen when user entered via tag number).
  final String? initialParkingLocation;

  const CameraBottomOverlay({
    super.key,
    required this.onCapture,
    this.onSubmit,
    this.positionAtTop = false,
    this.initialParkingLocation,
  });

  @override
  State<CameraBottomOverlay> createState() => _CameraBottomOverlayState();
}

class _CameraBottomOverlayState extends State<CameraBottomOverlay> {
  final TextEditingController _parkingLocationController =
      TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitLoading = false;

  Future<void> _runSubmit(BuildContext context, String parkingLocation) async {
    if (_isSubmitLoading) {
      return;
    }
    final onSubmit = widget.onSubmit;
    if (onSubmit == null) {
      return;
    }
    setState(() {
      _isSubmitLoading = true;
    });
    try {
      await onSubmit(context, parkingLocation);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initialParkingLocation;
    if (initial != null && initial.isNotEmpty) {
      _parkingLocationController.text = initial;
    }
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: widget.positionAtTop
          ? (isKeyboardOpen ? keyboardHeight + screenHeight * 0.01 : 0.0)
          : (isKeyboardOpen ? null : screenHeight * 0.7),
      bottom: widget.positionAtTop
          ? null
          : (isKeyboardOpen ? keyboardHeight + screenHeight * 0.01 : 0.0),
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.015, // Reduced vertical padding
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Prevent overflow
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parking Location Input Header
            TextComponent(
              labelText: 'Parking Location',
              color: AppColors.black,
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: screenHeight * 0.008), // Reduced spacing
            // Parking Location Input Field
            Container(
              height:
                  screenHeight * 0.06, // Increased height for better visibility
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _parkingLocationController,
                focusNode: _focusNode,
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: screenWidth * 0.04,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter parking location...',
                  hintStyle: TextStyle(
                    color: AppColors.grey.withOpacity(0.6),
                    fontSize: screenWidth * 0.04,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.018, // Slightly reduced padding
                  ),
                  border: InputBorder.none,
                ),
                maxLines: 1,
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  if (widget.onSubmit != null && value.trim().isNotEmpty) {
                    _runSubmit(context, value.trim());
                  }
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.012),
            // Submit Button - Full width, taller, with loader when submitting
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitLoading
                    ? null
                    : () {
                        final parkingLocation =
                            _parkingLocationController.text.trim();
                        if (parkingLocation.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  const Text('Please enter parking location'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }
                        if (widget.onSubmit != null) {
                          _runSubmit(context, parkingLocation);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.018,
                  ),
                  minimumSize: Size(double.infinity, screenHeight * 0.052),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    : Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _parkingLocationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
