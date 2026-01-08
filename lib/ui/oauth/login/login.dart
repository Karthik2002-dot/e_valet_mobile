import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/login/login_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/login/login_state.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/oauth/login/login_form.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/driver_home.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/operator_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _loginIdFocusNode = FocusNode();
  final FocusNode _pinFocusNode = FocusNode();

  @override
  void dispose() {
    _loginIdController.dispose();
    _pinController.dispose();
    _loginIdFocusNode.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            final roles =
                state.profile.roles.map((r) => r.toLowerCase()).toList();
            if (roles.contains('driver')) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const DriverHomeScreen(),
                ),
              );
            } else if (roles.contains('operator')) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const OperatorDashboardScreen(),
                ),
              );
            } else {
              // Unknown role - show error
              SnackBars.showErrorSnackBar(
                context,
                'Your account does not have the required permissions to access this application. Please contact your administrator.',
              );
            }
          } else if (state is LoginFailure) {
            SnackBars.showErrorSnackBar(context, state.message);
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: AppColors.white, // Light beige background
            appBar: const CustomAppBar(),
            body: SafeArea(
              child: Column(
                children: [
                  // Main content
                  Expanded(
                    child: Center(
                      child: LoginForm(
                        loginIdController: _loginIdController,
                        pinController: _pinController,
                        loginIdFocusNode: _loginIdFocusNode,
                        pinFocusNode: _pinFocusNode,
                      ),
                    ),
                  ),
                  // Footer
                  const Footer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
