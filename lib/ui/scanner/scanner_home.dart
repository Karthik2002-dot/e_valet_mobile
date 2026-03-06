import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/scanner/scanner_menu_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/scanner/scanner_menu_event.dart';
import 'package:niloufer_valet_mobile/bloc/scanner/scanner_menu_state.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/oauth/login/login.dart';
import 'package:niloufer_valet_mobile/ui/oauth/profile/overflow_menu.dart';
import 'package:niloufer_valet_mobile/ui/oauth/profile/profile_screen.dart';

/// Scanner role home screen: top bar (same style as driver) and menu with
/// Profile and Logout only.
class ScannerHomeScreen extends StatelessWidget {
  const ScannerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = screenWidth > 1200
        ? screenWidth * 0.08
        : screenWidth > 600
            ? screenWidth * 0.12
            : screenWidth * 0.2;
    final iconSize = screenWidth > 1200
        ? screenWidth * 0.02
        : screenWidth > 600
            ? screenWidth * 0.035
            : screenWidth * 0.06;

    return BlocProvider(
      create: (_) => ScannerMenuBloc(),
      child: BlocListener<ScannerMenuBloc, ScannerMenuState>(
        listener: (context, state) {
          if (state is ScannerMenuLogoutSuccess) {
            SnackBars.showSuccessSnackBar(context, state.response.message);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
            context.read<ScannerMenuBloc>().add(const ScannerMenuReset());
          } else if (state is ScannerMenuLogoutFailure) {
            SnackBars.showErrorSnackBar(context, state.message);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
            context.read<ScannerMenuBloc>().add(const ScannerMenuReset());
          } else if (state is ScannerMenuAction) {
            if (state.action == ScannerMenuActionType.profile) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
              context.read<ScannerMenuBloc>().add(const ScannerMenuReset());
            }
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.lightBeigeBackground,
          appBar: CustomAppBar(
            showLanguageIcon: true,
            logoSize: logoSize,
            iconSize: iconSize,
            actions: [
              const OverflowMenu(scannerMode: true),
              SizedBox(width: screenWidth * 0.04),
            ],
          ),
          body: const SafeArea(
            child: Center(
              child: Text('Scanner Home'),
            ),
          ),
        ),
      ),
    );
  }
}
