import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class CameraBottomOverlay extends StatefulWidget {
  final Function(BuildContext) onCapture;
  final Function(BuildContext, String)? onSubmit;

  const CameraBottomOverlay({
    super.key,
    required this.onCapture,
    this.onSubmit,
  });

  @override
  State<CameraBottomOverlay> createState() => _CameraBottomOverlayState();
}

class _CameraBottomOverlayState extends State<CameraBottomOverlay> {
  final TextEditingController _parkingLocationController =
      TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
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

    // Camera takes 70% of screen
    final cameraHeight = screenHeight * 0.7;

    // Calculate bottom position dynamically based on keyboard
    final bottomPosition =
        isKeyboardOpen ? keyboardHeight + screenHeight * 0.01 : 0.0;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: bottomPosition,
      left: 0,
      right: 0,
      top: isKeyboardOpen ? null : cameraHeight,
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
                    widget.onSubmit!(context, value.trim());
                  }
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.01), // Reduced spacing
            // Submit Button - Small button at right corner
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final parkingLocation =
                        _parkingLocationController.text.trim();
                    if (parkingLocation.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter parking location'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                    if (widget.onSubmit != null) {
                      widget.onSubmit!(context, parkingLocation);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical:
                          screenHeight * 0.008, // Reduced vertical padding
                    ),
                    minimumSize:
                        Size(0, screenHeight * 0.035), // Slightly reduced
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
