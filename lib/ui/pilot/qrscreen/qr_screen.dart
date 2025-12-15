import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/pilot/qr/qr_bloc.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';

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
    return BlocListener<QrBloc, QrState>(
      listenWhen: (previous, current) => previous.message != current.message,
      listener: (context, state) {
        final message = state.message;
        if (message == null || message.isEmpty) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        SnackBars.showSuccessSnackBar(context, message);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F0),
        body: Column(
          children: [
            const Footer(),
          ],
        ),
      ),
    );
  }
}
