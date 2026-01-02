import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
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

  void _onMenuItemSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _getBodyWidget() {
    return OperatorScreenRouter.getScreen(
        _selectedIndex, const DashboardContent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: OperatorDrawer(
        selectedIndex: _selectedIndex,
        onItemSelected: _onMenuItemSelected,
      ),
      appBar: CustomAppBar(
        showLanguageIcon: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: AppColors.white),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),
      body: _getBodyWidget(),
    );
  }
}
