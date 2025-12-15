import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_home/operator_menu_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_home/operator_menu_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_home/operator_menu_state.dart';
import 'package:niloufer_valet_mobile/ui/common/color.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/login/login.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_home/operator_overflow_menu.dart';
import 'package:niloufer_valet_mobile/ui/operator/profile/operator_profile_screen.dart';

class OperatorHomeScreen extends StatelessWidget {
  const OperatorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OperatorMenuBloc(),
      child: BlocListener<OperatorMenuBloc, OperatorMenuState>(
        listener: (context, state) {
          if (state is OperatorMenuAction) {
            switch (state.action) {
              case OperatorMenuActionType.logout:
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
                break;
              case OperatorMenuActionType.profile:
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const OperatorProfileScreen(),
                  ),
                );
                break;
            }
            // Reset state so the same action can be handled again later
            context.read<OperatorMenuBloc>().add(const OperatorMenuReset());
          }
        },
        child: const _OperatorHomeView(),
      ),
    );
  }
}

class _OperatorHomeView extends StatelessWidget {
  const _OperatorHomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Language icon
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Image.asset(
                    'assets/images/language.png',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 16),
                // Overflow menu using pull_down_button
                OperatorOverflowMenu(),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main content area
            Expanded(
              child: Center(
                child: TextComponent(
                  labelText: 'Operator Home',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),
            // Shared footer
            const Footer(),
          ],
        ),
      ),
    );
  }
}
