import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/confirm_handover/confirm_handover_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/confirm_handover/confirm_handover_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/confirm_handover/confirm_handover_state.dart';
import 'package:niloufer_valet_mobile/models/driver/session/assigned_session.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/driver/conifrm_handover/confirm_handover_widgets/handover_buttons_section.dart';

class ConfirmHandoverScreen extends StatefulWidget {
  final AssignedSession session;

  const ConfirmHandoverScreen({
    super.key,
    required this.session,
  });

  @override
  State<ConfirmHandoverScreen> createState() => _ConfirmHandoverScreenState();
}

class _ConfirmHandoverScreenState extends State<ConfirmHandoverScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConfirmHandoverBloc(),
      child: BlocListener<ConfirmHandoverBloc, ConfirmHandoverState>(
        listener: (context, state) {
          if (state is ConfirmHandoverSuccess) {
            SnackBars.showSuccessSnackBar(context, state.message);
            // TODO: Navigate to next screen or close
            Navigator.of(context).pop();
          } else if (state is ConfirmHandoverError) {
            SnackBars.showErrorSnackBar(context, state.message);
          } else if (state is ConfirmHandoverValidationError) {
            SnackBars.showErrorSnackBar(context, state.message);
          }
        },
        child: BlocBuilder<ConfirmHandoverBloc, ConfirmHandoverState>(
          builder: (context, state) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final isLoading = state is ConfirmHandoverLoading;

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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: screenHeight * 0.04),

                            // Title
                            TextComponent(
                              labelText: TextConstants.confirmationHandover,
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),

                            SizedBox(height: screenHeight * 0.03),

                            // Handover instruction
                            TextComponent(
                              labelText:
                                  'Please handover the key to the customer and click on the confirm handover button',
                              textAlign: TextAlign.center,
                              fontSize: screenWidth * 0.045,
                              color: AppColors.black,
                              height: 1.4,
                            ),

                            SizedBox(height: screenHeight * 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Buttons at bottom - always visible
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.02,
                    ),
                    child: HandoverButtonsSection(
                      isLoading: isLoading,
                      onConfirmHandover: () {
                        context.read<ConfirmHandoverBloc>().add(
                              ConfirmHandoverRequested(
                                sessionId: widget.session.id,
                              ),
                            );
                      },
                      onCustomerMissing: () {
                        // TODO: Handle customer missing
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
