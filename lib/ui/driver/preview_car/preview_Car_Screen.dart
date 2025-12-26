import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/driver/preview_car/preview_Car_widgets/preview_header.dart';
import 'package:niloufer_valet_mobile/ui/driver/preview_car/preview_Car_widgets/preview_image_card.dart';
import 'package:niloufer_valet_mobile/ui/driver/preview_car/preview_Car_widgets/preview_submit_button.dart';
import 'package:niloufer_valet_mobile/ui/driver/car_Camera/car_Success.dart';
import 'package:niloufer_valet_mobile/bloc/driver/preview_car/preview_car_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/preview_car/preview_car_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/preview_car/preview_car_state.dart';

class PreviewCarScreen extends StatefulWidget {
  final String imagePath;

  const PreviewCarScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<PreviewCarScreen> createState() => _PreviewCarScreenState();
}

class _PreviewCarScreenState extends State<PreviewCarScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (context) => PreviewCarBloc(),
      child: BlocListener<PreviewCarBloc, PreviewCarState>(
        listener: (context, state) {
          if (state is PreviewCarSuccess) {
            // Navigate to success screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const CarSuccessScreen(),
              ),
            );
          } else if (state is PreviewCarError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        child: BlocBuilder<PreviewCarBloc, PreviewCarState>(
          builder: (context, state) {
            final isSubmitting = state is PreviewCarSubmitting;

            return Scaffold(
              backgroundColor: AppColors.lightBeigeBackground,
              appBar: const CustomAppBar(),
              body: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Review Entry Header
                        const PreviewHeader(),
                        SizedBox(height: screenHeight * 0.02),

                        // Image Card with Retake Button
                        PreviewImageCard(
                          imagePath: widget.imagePath,
                          onRetake: () => Navigator.pop(context),
                        ),

                        const Spacer(),

                        // Submit Button
                        PreviewSubmitButton(
                          onSubmit: isSubmitting
                              ? () {}
                              : () => context.read<PreviewCarBloc>().add(
                                    SubmitPhotoRequested(widget.imagePath),
                                  ),
                        ),

                        // Footer with "Powered By" and logo
                        const Footer(),
                      ],
                    ),
                  ),

                  // Loading overlay when submitting
                  if (isSubmitting)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
