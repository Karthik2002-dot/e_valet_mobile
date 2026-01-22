import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_dashboard/operator_dashboard_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/operator/operator_dashboard/operator_dashboard_state.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/skeleton_loader.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_slots/widgets/slots_content_view.dart';

class OperatorSlotsScreen extends StatelessWidget {
  const OperatorSlotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<OperatorDashboardBloc, OperatorDashboardState>(
        builder: (context, state) {
          if (state is OperatorDashboardLoading) {
            return _buildLoadingState(context);
          }

          if (state is OperatorDashboardLoaded) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.width * 0.02,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextComponent(
                    labelText: TextConstants.parkedCarTitle,
                    color: AppColors.black,
                    fontSize: MediaQuery.of(context).size.width * 0.02,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  TextComponent(
                    labelText: TextConstants.parkedCarDescription,
                    color: AppColors.grey,
                    fontSize: MediaQuery.of(context).size.width * 0.013,
                  ),
                  const SizedBox(height: 24),
                  SlotsContentView(
                    digitalKeyRack: state.digitalKeyRack,
                  ),
                ],
              ),
            );
          }

          if (state is OperatorDashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: MediaQuery.of(context).size.width * 0.08,
                    color: AppColors.error,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  TextComponent(
                    labelText: 'Failed to load slots data',
                    fontSize: MediaQuery.of(context).size.width * 0.02,
                    color: AppColors.error,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  TextComponent(
                    labelText: state.message,
                    fontSize: MediaQuery.of(context).size.width * 0.016,
                    color: AppColors.grey,
                  ),
                ],
              ),
            );
          }

          return _buildLoadingState(context);
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            height: MediaQuery.of(context).size.height * 0.03,
            width: MediaQuery.of(context).size.width * 0.3,
            borderRadius: 4,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          SkeletonLoader(
            height: MediaQuery.of(context).size.height * 0.02,
            width: MediaQuery.of(context).size.width * 0.5,
            borderRadius: 4,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Row(
            children: [
              Expanded(
                child: SkeletonLoader(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: double.infinity,
                  borderRadius: 12,
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.015),
              Expanded(
                child: SkeletonLoader(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: double.infinity,
                  borderRadius: 12,
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.015),
              Expanded(
                child: SkeletonLoader(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: double.infinity,
                  borderRadius: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
