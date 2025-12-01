import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary, // Yellow
      elevation: 0,
      automaticallyImplyLeading: false,
      title: SizedBox(
        width: 60,
        height: 60,
        child: Image.asset('assets/images/niloufer.logo.png'),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

