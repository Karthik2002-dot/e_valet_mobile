import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/profile/operator_profile_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/profile/operator_profile_event.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/profile/operator_profile_state.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/core/profile/operator_profile_content.dart';

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
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                        textAlign: TextAlign.center,
                      );
                    }

                    if (state is OperatorProfileLoaded) {
                      return OperatorProfileContent(profile: state.profile);
                    }

                    // Fallback – shouldn't normally reach here
                    return const SizedBox.shrink();
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
