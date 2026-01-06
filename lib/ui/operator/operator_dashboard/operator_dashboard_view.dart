import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_home/operator_menu_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_home/operator_menu_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_home/operator_menu_state.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/oauth/login/login.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/operator_content.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_drawer/operator_drawer.dart';
import 'operator_screen_router.dart';

class OperatorDashboardView extends StatefulWidget {
  const OperatorDashboardView({super.key});

  @override
  State<OperatorDashboardView> createState() => _OperatorDashboardViewState();
}

class _OperatorDashboardViewState extends State<OperatorDashboardView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  int _refreshKey = 0;

  void _onMenuItemSelected(int index) {
    if (index == 5) {
      // Logout
      context.read<OperatorMenuBloc>().add(const OperatorMenuLogoutRequested());
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  void _refreshDashboard() {
    setState(() {
      _refreshKey++;
    });
  }

  Widget _getBodyWidget() {
    return OperatorScreenRouter.getScreen(
        _selectedIndex, DashboardContent(key: ValueKey(_refreshKey)), _refreshKey);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OperatorMenuBloc(),
      child: BlocListener<OperatorMenuBloc, OperatorMenuState>(
        listener: (context, state) {
          if (state is OperatorMenuLogoutSuccess) {
            SnackBars.showSuccessSnackBar(context, state.message);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
              (route) => false,
            );
          } else if (state is OperatorMenuLogoutFailure) {
            SnackBars.showErrorSnackBar(context, state.message);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
              (route) => false,
            );
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          drawer: OperatorDrawer(
            selectedIndex: _selectedIndex,
            onItemSelected: _onMenuItemSelected,
          ),
          appBar: CustomAppBar(
            showLanguageIcon: true,
            actions: [
              IconButton(
                onPressed: _refreshDashboard,
                icon: const Icon(Icons.refresh, color: AppColors.white),
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: AppColors.white),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ],
          ),
          body: _getBodyWidget(),
        ),
      ),
    );
  }
}
