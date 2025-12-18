import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/operator_menu_event.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/operator_menu_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';

class OperatorOverflowMenu extends StatelessWidget {
  const OperatorOverflowMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          title: TextConstants.profileMenuTitle,
          icon: Icons.person_outline,
          onTap: () {
            context
                .read<OperatorMenuBloc>()
                .add(const OperatorProfilePressed());
          },
        ),
        const PullDownMenuDivider(),
        PullDownMenuItem(
          title: TextConstants.logoutMenuTitle,
          icon: Icons.logout,
          onTap: () {
            context.read<OperatorMenuBloc>().add(const OperatorLogoutPressed());
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
