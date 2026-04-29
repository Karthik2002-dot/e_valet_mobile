import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/oauth/profile/overflow_menu.dart';
import 'package:niloufer_valet_mobile/ui/common/translations/language_dropdown_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onLogoTap;
  final bool showLanguageIcon;
  final bool showOverflowMenu;
  final Color backgroundColor;
  final double? logoSize;
  final double? iconSize;

  const CustomAppBar({
    super.key,
    this.leading,
    this.actions,
    this.onLogoTap,
    this.showLanguageIcon = false,
    this.showOverflowMenu = false,
    this.backgroundColor = AppColors.primary,
    this.logoSize,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final defaultLogoSize = logoSize ?? 60;
    final defaultIconSize = iconSize ?? screenWidth * 0.06;

    // Build actions:
    // - If [actions] is provided, use it as-is (caller fully controls the right side).
    // - Otherwise, optionally show language selector and/or the overflow menu.
    List<Widget>? appBarActions;
    if (actions != null) {
      appBarActions = actions;
    } else {
      final built = <Widget>[];
      if (showLanguageIcon) {
        built.add(LanguageDropdownButton(iconSize: defaultIconSize));
        built.add(SizedBox(width: screenWidth * 0.04));
      }
      if (showOverflowMenu) {
        // Only show the driver overflow menu when the DriverMenuBloc is available.
        // This app bar is also used on operator/auth screens.
        DriverMenuBloc? driverMenuBloc;
        try {
          driverMenuBloc =
              BlocProvider.of<DriverMenuBloc>(context, listen: false);
        } catch (_) {
          driverMenuBloc = null;
        }
        if (driverMenuBloc != null) {
          built.add(const OverflowMenu());
          built.add(SizedBox(width: screenWidth * 0.04));
        }
      }
      appBarActions = built.isEmpty ? null : built;
    }

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: leading,
      title: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onLogoTap,
        child: SizedBox(
          width: defaultLogoSize,
          height: defaultLogoSize,
          child: Image.asset(
            'assets/images/niloufer.logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
      actions: appBarActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
