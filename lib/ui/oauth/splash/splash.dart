import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:niloufer_valet_mobile/bloc/splash/splash_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/splash/splash_event.dart';
import 'package:niloufer_valet_mobile/bloc/splash/splash_state.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/version/version_check_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    context.read<SplashBloc>().add(const SplashStarted());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onAnimationComplete() {
    context.read<SplashBloc>().add(const SplashAnimationCompleted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashCompleted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => VersionCheckScreen(
                args: VersionCheckArgs(
                  isAuthenticated: state.isAuthenticated,
                  roles: state.roles,
                ),
              ),
            ),
          );
        }
      },
      child: BlocBuilder<SplashBloc, SplashState>(
        builder: (context, state) {
          final isLandscape =
              MediaQuery.of(context).orientation == Orientation.landscape;
          final splashAsset = isLandscape
              ? 'assets/jsons/horizontal_splash.json'
              : 'assets/jsons/splash.json';

          return Scaffold(
            backgroundColor: AppColors.white,
            body: state is SplashError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        TextComponent(
                          labelText: state.message,
                          fontSize: 16,
                          color: AppColors.error,
                        ),
                      ],
                    ),
                  )
                : SizedBox.expand(
                    child: Lottie.asset(
                      splashAsset,
                      controller: _animationController,
                      onLoaded: (composition) {
                        _animationController
                          ..duration = composition.duration
                          ..forward().then((_) => _onAnimationComplete());
                      },
                      fit: BoxFit.fill,
                      repeat: false,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
