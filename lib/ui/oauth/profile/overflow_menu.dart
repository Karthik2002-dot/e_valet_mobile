import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_event.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class OverflowMenu extends StatelessWidget {
  const OverflowMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          title: TextConstants.profileMenuTitle,
          icon: Icons.person_outline,
          onTap: () {
            context.read<DriverMenuBloc>().add(const DriverProfilePressed());
          },
        ),
        PullDownMenuItem(
          title: TextConstants.helpMenuTitle,
          icon: Icons.support_agent,
          onTap: () {
            context.read<DriverMenuBloc>().add(const DriverHelpPressed());
          },
        ),
        PullDownMenuItem(
          title: TextConstants.guidelinesMenuTitle,
          icon: Icons.menu_book_outlined,
          onTap: () {
            context.read<DriverMenuBloc>().add(const DriverGuidelinesPressed());
          },
        ),
        const PullDownMenuDivider(),
        PullDownMenuItem(
          title: TextConstants.logoutMenuTitle,
          icon: Icons.logout,
          onTap: () {
            context.read<DriverMenuBloc>().add(const DriverLogoutPressed());
          },
        ),
      ],
      buttonBuilder: (context, showMenu) {
        return IconButton(
          icon: const Icon(
            Icons.more_vert,
            color: AppColors.white,
          ),
          onPressed: showMenu,
        );
      },
    );
  }
}
