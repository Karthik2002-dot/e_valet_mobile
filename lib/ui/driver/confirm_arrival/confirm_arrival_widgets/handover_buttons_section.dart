import 'dart:async';

import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class HandoverButtonsSection extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onConfirmHandover;
  final Future<void> Function()? onCustomerMissing;

  /// When set, Customer Missing button is disabled until this time; countdown shown in place of icon.
  final DateTime? customerMissingDisabledUntil;

  const HandoverButtonsSection({
    super.key,
    required this.isLoading,
    required this.onConfirmHandover,
    this.onCustomerMissing,
    this.customerMissingDisabledUntil,
  });

  @override
  State<HandoverButtonsSection> createState() => HandoverButtonsSectionState();
}

class HandoverButtonsSectionState extends State<HandoverButtonsSection> {
  Key _customerMissingKey = UniqueKey();
  bool _isCustomerMissingLoading = false;
  int _customerMissingRemainingSeconds = 0;
  Timer? _customerMissingCountdownTimer;

  void resetCustomerMissingButton() {
    setState(() {
      _customerMissingKey = UniqueKey();
    });
  }

  int _remainingSeconds(DateTime? until) {
    if (until == null) return 0;
    final sec = until.difference(DateTime.now()).inSeconds;
    return sec > 0 ? sec : 0;
  }

  void _startCountdownIfNeeded() {
    _customerMissingCountdownTimer?.cancel();
    final until = widget.customerMissingDisabledUntil;
    final remaining = _remainingSeconds(until);
    if (remaining <= 0) {
      if (_customerMissingRemainingSeconds != 0) {
        setState(() => _customerMissingRemainingSeconds = 0);
      }
      return;
    }
    setState(() => _customerMissingRemainingSeconds = remaining);
    _customerMissingCountdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;
        final r = _remainingSeconds(widget.customerMissingDisabledUntil);
        if (r <= 0) {
          _customerMissingCountdownTimer?.cancel();
          _customerMissingCountdownTimer = null;
          setState(() => _customerMissingRemainingSeconds = 0);
          return;
        }
        setState(() => _customerMissingRemainingSeconds = r);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _startCountdownIfNeeded();
  }

  @override
  void didUpdateWidget(HandoverButtonsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customerMissingDisabledUntil !=
        widget.customerMissingDisabledUntil) {
      _startCountdownIfNeeded();
    }
  }

  @override
  void dispose() {
    _customerMissingCountdownTimer?.cancel();
    super.dispose();
  }

  Widget _buildActionButton({
    Key? key,
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    required bool isLoading,
    required VoidCallback? onPressed,
    required bool bigStyle,

    /// When > 0, button is disabled and this number is shown in place of the icon (countdown).
    int countdownSeconds = 0,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDisabledByCountdown = countdownSeconds > 0;
    final effectiveOnPressed =
        (isLoading || isDisabledByCountdown) ? null : onPressed;

    final leadingWidget = isDisabledByCountdown
        ? Text(
            '$countdownSeconds',
            style: TextStyle(
              fontSize: bigStyle ? screenWidth * 0.08 : screenHeight * 0.03,
              fontWeight: FontWeight.w700,
              color: foregroundColor.withOpacity(0.7),
            ),
          )
        : Icon(
            icon,
            size: bigStyle ? screenWidth * 0.08 : screenHeight * 0.03,
            color: foregroundColor,
          );

    final button = ElevatedButton(
      onPressed: effectiveOnPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: backgroundColor.withOpacity(0.7),
        disabledForegroundColor: foregroundColor.withOpacity(0.7),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                leadingWidget,
                SizedBox(width: bigStyle ? 16 : 10),
                TextComponent(
                  labelText: label,
                  fontSize:
                      bigStyle ? screenWidth * 0.06 : screenHeight * 0.025,
                  fontWeight: FontWeight.w600,
                  color: isDisabledByCountdown
                      ? foregroundColor.withOpacity(0.7)
                      : foregroundColor,
                ),
              ],
            ),
    );

    if (bigStyle) {
      return Expanded(
        child: SizedBox(key: key, width: double.infinity, child: button),
      );
    }
    return SizedBox(
      key: key,
      width: double.infinity,
      height: screenHeight * 0.07,
      child: button,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildActionButton(
          label: TextConstants.slideToConfirmHandover,
          icon: Icons.handshake,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.black,
          isLoading: widget.isLoading,
          onPressed: widget.onConfirmHandover,
          bigStyle: true,
        ),
        SizedBox(height: screenHeight * 0.02),
        _buildActionButton(
          key: _customerMissingKey,
          label: TextConstants.slideToCustomerMissing,
          icon: Icons.warning,
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.white,
          isLoading: _isCustomerMissingLoading,
          onPressed: () async {
            if (_isCustomerMissingLoading) return;
            final onCustomerMissing = widget.onCustomerMissing;
            if (onCustomerMissing == null) return;
            setState(() => _isCustomerMissingLoading = true);
            try {
              await onCustomerMissing();
            } finally {
              if (mounted) {
                setState(() => _isCustomerMissingLoading = false);
              }
            }
          },
          bigStyle: true,
          countdownSeconds: _customerMissingRemainingSeconds,
        ),
      ],
    );
  }
}
