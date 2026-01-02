import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class SlideToConfirmButton extends StatefulWidget {
  final String sessionId;
  final bool isLoading;
  final VoidCallback onConfirm;

  const SlideToConfirmButton({
    super.key,
    required this.sessionId,
    required this.isLoading,
    required this.onConfirm,
  });

  @override
  State<SlideToConfirmButton> createState() => _SlideToConfirmButtonState();
}

class _SlideToConfirmButtonState extends State<SlideToConfirmButton> {
  double _dragPosition = 0.0;
  bool _isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final buttonHeight = screenHeight * 0.07;
    final maxDrag = screenWidth - buttonHeight - 32; // 32 is padding

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (!_isConfirmed && !widget.isLoading) {
          setState(() {
            _dragPosition =
                (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
            if (_dragPosition >= maxDrag * 0.9) {
              _isConfirmed = true;
              widget.onConfirm();
            }
          });
        }
      },
      onHorizontalDragEnd: (details) {
        if (!_isConfirmed && !widget.isLoading) {
          setState(() {
            _dragPosition = 0.0;
          });
        }
      },
      child: Container(
        width: double.infinity,
        height: buttonHeight,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow10,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Text
            Center(
              child: widget.isLoading
                  ? const CircularProgressIndicator()
                  : TextComponent(
                      labelText: TextConstants.slideToConfirmArrival,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
            ),
            // Slidable button
            Positioned(
              left: _dragPosition,
              child: Container(
                width: buttonHeight,
                height: buttonHeight,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: widget.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                        ),
                      )
                    : Icon(
                        Icons.arrow_forward,
                        color: AppColors.white,
                        size: screenWidth * 0.06,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
