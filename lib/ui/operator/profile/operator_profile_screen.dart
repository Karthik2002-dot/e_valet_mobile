import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/profile/operator_profile_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/profile/operator_profile_event.dart';
import 'package:niloufer_valet_mobile/bloc/operator/profile/operator_profile_state.dart';
import 'package:niloufer_valet_mobile/ui/common/color.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class OperatorProfileScreen extends StatelessWidget {
  const OperatorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OperatorProfileBloc()..add(const OperatorProfileStarted()),
      child: const _OperatorProfileView(),
    );
  }
}

class _OperatorProfileView extends StatelessWidget {
  const _OperatorProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: BlocBuilder<OperatorProfileBloc, OperatorProfileState>(
                  builder: (context, state) {
                    if (state is OperatorProfileLoading ||
                        state is OperatorProfileInitial) {
                      return const CircularProgressIndicator();
                    }

                    if (state is OperatorProfileError) {
                      return TextComponent(
                        labelText: state.message,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                        textAlign: TextAlign.center,
                      );
                    }

                    // Loaded state – placeholder content for now
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 72,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        const TextComponent(
                          labelText: 'Operator Profile',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                        const SizedBox(height: 8),
                        TextComponent(
                          labelText: 'Profile details will appear here.',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }
}
