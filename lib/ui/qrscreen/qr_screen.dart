import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/qr/qr_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/color.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/texts.dart';
import 'package:niloufer_valet_mobile/widgets/qr_screen_header.dart';
import 'package:niloufer_valet_mobile/widgets/qr_screen_content.dart';

class QRScreen extends StatelessWidget {
  const QRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QrBloc(),
      child: const _QrScreenView(),
    );
  }
}

class _QrScreenView extends StatelessWidget {
  const _QrScreenView();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const headerHeight = 196.0;

    return BlocListener<QrBloc, QrState>(
      listenWhen: (previous, current) => previous.message != current.message,
      listener: (context, state) {
        final message = state.message;
        if (message == null || message.isEmpty) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: TextComponent(
                labelText: message,
                fontSize: 14,
                color: AppColors.white,
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.headerYellow,
            ),
          );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F0),
        body: Column(
          children: [
            QrScreenHeader(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              headerHeight: headerHeight,
            ),
            QrScreenContent(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }
}
