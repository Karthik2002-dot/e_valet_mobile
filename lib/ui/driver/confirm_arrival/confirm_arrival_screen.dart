import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/confirm_arrival/confirm_arrival_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/confirm_arrival/confirm_arrival_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/confirm_arrival/confirm_arrival_state.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/driver/confirm_arrival/confirm_arrival_widgets/car_information_card.dart';
import 'package:niloufer_valet_mobile/ui/driver/confirm_arrival/confirm_arrival_widgets/slide_to_confirm_button.dart';
import 'package:niloufer_valet_mobile/ui/driver/conifrm_handover/confirm_handover.dart';

class ConfirmArrivalScreen extends StatelessWidget {
  final AssignedSession session;

  const ConfirmArrivalScreen({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConfirmArrivalBloc(),
      child: BlocListener<ConfirmArrivalBloc, ConfirmArrivalState>(
        listener: (context, state) {
          if (state is ConfirmArrivalSuccess) {
            SnackBars.showSuccessSnackBar(context, state.message);
            // Navigate to confirm handover screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ConfirmHandoverScreen(session: session),
              ),
            );
          } else if (state is ConfirmArrivalError) {
            if (state.shouldNavigateToHandover) {
              SnackBars.showSuccessSnackBar(context, state.message);
              // Navigate to confirm handover screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ConfirmHandoverScreen(session: session),
                ),
              );
            } else {
              SnackBars.showErrorSnackBar(context, state.message);
            }
          }
        },
        child: BlocBuilder<ConfirmArrivalBloc, ConfirmArrivalState>(
          builder: (context, state) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final isLoading = state is ConfirmArrivalLoading;

            return Scaffold(
              backgroundColor: AppColors.lightBeigeBackground,
              appBar: const CustomAppBar(),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: screenHeight * 0.02),
                            // Title
                            Center(
                              child: TextComponent(
                                labelText: TextConstants.retrievalRequest,
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            // Car Information Card
                            CarInformationCard(session: session),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Slide to Confirm Arrival Button at Bottom
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.02,
                    ),
                    child: SlideToConfirmButton(
                      sessionId: session.id,
                      isLoading: isLoading,
                      onConfirm: () {
                        context.read<ConfirmArrivalBloc>().add(
                              ConfirmArrivalRequested(sessionId: session.id),
                            );
                      },
                    ),
                  ),

                  // Footer at Bottom
                  const Footer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
