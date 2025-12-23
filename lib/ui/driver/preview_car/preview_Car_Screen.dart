import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/driver/preview_car/preview_Car_widgets/preview_header.dart';
import 'package:niloufer_valet_mobile/ui/driver/preview_car/preview_Car_widgets/preview_image_card.dart';
import 'package:niloufer_valet_mobile/ui/driver/preview_car/preview_Car_widgets/preview_submit_button.dart';
import 'package:niloufer_valet_mobile/api/driver/image_API.dart';
import 'package:niloufer_valet_mobile/models/core/api_exceptions.dart';
import 'package:niloufer_valet_mobile/ui/driver/car_Camera/car_Success.dart';

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
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
                  onSubmit: _isSubmitting ? () {} : () => _handleSubmit(context),
                ),

                // Footer with "Powered By" and logo
                const Footer(),
              ],
            ),
          ),

          // Loading overlay when submitting
          if (_isSubmitting)
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
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Upload the parking photo
      await ImageApiService.uploadParkingPhoto(
        imagePath: widget.imagePath,
      );

      if (!mounted) return;

      // Navigate to success screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const CarSuccessScreen(),
        ),
      );
    } on ApiException catch (e) {
      print('❌ API ERROR: ${e.code} - ${e.message}');
      
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      print('❌ UNEXPECTED ERROR: $e (${e.runtimeType})');
      
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      // Show generic error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to upload photo. Please try again.'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
}

