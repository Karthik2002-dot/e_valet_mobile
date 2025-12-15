import 'package:flutter/material.dart';
import 'package:niloufer_valet_mobile/ui/common/color.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';

class OperatorHomeScreen extends StatelessWidget {
  const OperatorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Language icon
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Image.asset(
                    'assets/images/language.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16),
                // 3-dots menu icon
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.white,
                  ),
                  onPressed: () {
                    // TODO: open operator menu / overflow actions
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main content area
            Expanded(
              child: Center(
                child: TextComponent(
                  labelText: 'Operator Home',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),
            // Shared footer
            const Footer(),
          ],
        ),
      ),
    );
  }
}
