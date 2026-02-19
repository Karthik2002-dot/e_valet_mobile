import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/oauth/profile/overflow_menu.dart';
import 'package:niloufer_valet_mobile/ui/common/translations/language_dropdown_button.dart';

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

    // Build actions: when showLanguageIcon is true, always show language first; then default or custom actions
    List<Widget>? appBarActions;
    if (showLanguageIcon) {
      appBarActions = [
        LanguageDropdownButton(iconSize: defaultIconSize),
        SizedBox(width: screenWidth * 0.04),
        ...(actions ?? [
          OverflowMenu(),
          SizedBox(width: screenWidth * 0.04),
        ]),
      ];
    } else {
      appBarActions = actions;
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
