import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_home/operator_menu_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_home/operator_menu_event.dart';

class OperatorHomeView extends StatelessWidget {
  const OperatorHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operator Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Trigger a logout or menu action
              context.read<OperatorMenuBloc>().add(const OperatorMenuLogoutRequested());
            },
          )
        ],
      ),
      body: const Center(
        child: Text('Welcome, Operator!'),
      ),
    );
  }
}