import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class SlideActionButton extends StatefulWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onConfirm;
  final Color? buttonColor;
  final Color? textColor;
  final IconData? icon;

  const SlideActionButton({
    super.key,
    required this.text,
    required this.isLoading,
    required this.onConfirm,
    this.buttonColor,
    this.textColor,
    this.icon,
  });

  @override
  State<SlideActionButton> createState() => _SlideActionButtonState();
}

class _SlideActionButtonState extends State<SlideActionButton> {
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
                      labelText: widget.text,
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: widget.textColor ?? AppColors.black,
                    ),
            ),
            // Slidable button
            Positioned(
              left: _dragPosition,
              child: Container(
                width: buttonHeight,
                height: buttonHeight,
                decoration: BoxDecoration(
                  color: widget.buttonColor ?? AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: widget.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                        ),
                      )
                    : Icon(
                        widget.icon ?? Icons.arrow_forward,
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
