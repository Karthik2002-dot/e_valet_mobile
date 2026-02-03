import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/oauth/profile/overflow_menu.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final List<Widget>? actions;
  final bool showLanguageIcon;
  final double? logoSize;
  final double? iconSize;

  const CustomAppBar({
    super.key,
    this.leading,
    this.actions,
    this.showLanguageIcon = false,
    this.logoSize,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final defaultLogoSize = logoSize ?? 60;
    final defaultIconSize = iconSize ?? screenWidth * 0.06;

    // Build default actions with language icon and menu if needed
    List<Widget>? appBarActions = actions;
    if (showLanguageIcon && actions == null) {
      appBarActions = [
        SizedBox(
          width: defaultIconSize,
          height: defaultIconSize,
          child: Image.asset(
            'assets/images/language.png',
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(width: screenWidth * 0.04),
        OverflowMenu(),
        SizedBox(width: screenWidth * 0.04),
      ];
    }

    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: leading,
      title: SizedBox(
        width: defaultLogoSize,
        height: defaultLogoSize,
        child: Image.asset(
          'assets/images/niloufer.logo.png',
          fit: BoxFit.contain,
        ),
      ),
      actions: appBarActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
