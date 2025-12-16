import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:niloufer_valet_mobile/bloc/splash/splash_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/splash/splash_event.dart';
import 'package:niloufer_valet_mobile/bloc/splash/splash_state.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/text.dart';
import 'package:niloufer_valet_mobile/ui/login/login.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_home/operator_home.dart';

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
          if (state.isAuthenticated) {
            // User is already logged in, navigate to home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const OperatorHomeScreen(),
              ),
            );
          } else {
            // User is not logged in, navigate to login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        }
      },
      child: BlocBuilder<SplashBloc, SplashState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: state is SplashError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        TextComponent(
                          labelText: state.message,
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  )
                : SizedBox.expand(
                    child: Lottie.asset(
                      'assets/jsons/splash.json',
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
