import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/typography.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
/// Full-width coral CTA with optional 24px countdown badge on the left.
class CountdownCtaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final int countdownSeconds;
  final IconData? iconWhenEnabled;
  final double? height;

  const CountdownCtaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.countdownSeconds = 0,
    this.iconWhenEnabled,
    this.height = 48,
  });

  static Widget countdownBadge(int seconds) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.nearBlack.withValues(alpha: 0.35),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$seconds',
        style: AppTypography.style(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final disabled = countdownSeconds > 0;
    final effectiveOnPressed =
        (isLoading || disabled) ? null : onPressed;

    Widget leading;
    if (isLoading) {
      leading = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      );
    } else if (disabled) {
      leading = countdownBadge(countdownSeconds);
    } else if (iconWhenEnabled != null) {
      leading = Icon(iconWhenEnabled, color: AppColors.white, size: 22);
    } else {
      leading = const SizedBox(width: 24);
    }

    final button = ElevatedButton(
      onPressed: effectiveOnPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.coral,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.coral.withValues(alpha: 0.7),
        disabledForegroundColor: AppColors.white.withValues(alpha: 0.85),
        elevation: 0,
        minimumSize: Size(double.infinity, height ?? 48),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          leading,
          const SizedBox(width: 12),
          Flexible(
            child: TextComponent(
              labelText: label,
              fontSize: AppTypography.cta,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    return Semantics(
      button: true,
      enabled: effectiveOnPressed != null,
      label: disabled ? '$label, disabled for $countdownSeconds seconds' : label,
      child: button,
    );
  }
}
