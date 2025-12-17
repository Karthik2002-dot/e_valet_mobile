import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_home/operator_menu_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_home/operator_menu_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_home/operator_menu_state.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_home/operator_home_content.dart';

class OperatorHomeView extends StatelessWidget {
  const OperatorHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OperatorMenuBloc, OperatorMenuState>(
      builder: (context, state) {
        if (state is! OperatorHomeLoaded) {
          // Trigger loading if not already loaded
          if (state is OperatorMenuInitial) {
            context.read<OperatorMenuBloc>().add(const OperatorHomeStarted());
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final operatorName = state.operatorName;
        final isOnBreak = state.isOnBreak;
        final isOnline = state.isOnline;

        return OperatorHomeContent(
          operatorName: operatorName,
          isOnBreak: isOnBreak,
          isOnline: isOnline,
        );
      },
    );
  }
}
