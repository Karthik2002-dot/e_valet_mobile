import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_drawer/operator_drawer.dart';

class OperatorHomeView extends StatefulWidget {
  const OperatorHomeView({super.key});

  @override
  State<OperatorHomeView> createState() => _OperatorHomeViewState();
}

class _OperatorHomeViewState extends State<OperatorHomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  void _onMenuItemSelected(int index) {
    setState(() => _selectedIndex = index);
    // TODO: add navigation for each menu item if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: OperatorDrawer(selectedIndex: _selectedIndex, onItemSelected: _onMenuItemSelected),
      appBar: AppBar(
        title: const Text('Operator Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Open the custom drawer (hamburger)
              _scaffoldKey.currentState?.openDrawer();
            },
          )
        ],
      ),
      body: Center(
        child: Text('Welcome, Operator! (Menu: $_selectedIndex)'),
      ),
    );
  }
}