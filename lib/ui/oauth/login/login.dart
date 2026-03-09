import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_event.dart';
import 'package:niloufer_valet_mobile/bloc/websocket/websocket_bloc.dart';
import 'package:provider/provider.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/login/login_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/login/login_state.dart';
import 'package:niloufer_valet_mobile/services/notification/firebase_messaging_service.dart';
import 'package:niloufer_valet_mobile/ui/common/colors.dart';
import 'package:niloufer_valet_mobile/ui/guidelines/guidelines_screen.dart';
import 'package:niloufer_valet_mobile/ui/help_support/help_screen.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/custom_app_bar.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/footer.dart';
import 'package:niloufer_valet_mobile/services/translations/app_translations_notifier.dart';
import 'package:niloufer_valet_mobile/ui/common/text_constants.dart';
import 'package:niloufer_valet_mobile/ui/common/widgets/snack_bar.dart';
import 'package:niloufer_valet_mobile/ui/oauth/login/login_form.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_event.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_home/driver_menu_state.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/status/clock_in_too_far_screen.dart';
import 'package:niloufer_valet_mobile/ui/driver/driver_home/driver_home.dart';
import 'package:niloufer_valet_mobile/ui/oauth/profile/profile_screen.dart';
import 'package:niloufer_valet_mobile/ui/operator/operator_dashboard/operator_dashboard.dart';
import 'package:niloufer_valet_mobile/ui/scanner/scanner_home.dart';

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

  void _navigateToDriverHome(BuildContext context) {
    // Navigate to driver home screen - permissions will be requested there
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DriverHomeScreen(),
        ),
      );
      // Dispatch event to refresh driver status after navigation
      context.read<DriverStatusBloc>().add(const DriverStatusStarted());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get FirebaseMessagingService from Provider
    final firebaseMessagingService = Provider.of<FirebaseMessagingService>(
      context,
      listen: false,
    );





    // Get WebSocketBloc from context
    final webSocketBloc = context.read<WebSocketBloc>();

    

    return BlocProvider(
      create: (context) => LoginBloc(
        firebaseMessagingService: firebaseMessagingService,
        webSocketBloc: webSocketBloc,
      ),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            final roles =
                state.profile.roles.map((r) => r.toLowerCase()).toList();

            // Priority: scanner → operator/admin → driver
            if (roles.any((r) => r.contains('scanner'))) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const ScannerHomeScreen(),
                ),
              );
            } else if (roles.any((r) =>
                r.contains('operator') || r.contains('admin'))) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const OperatorDashboardScreen(),
                ),
              );
            } else if (roles.any((r) => r.contains('driver'))) {
              _navigateToDriverHome(context);
            } else {
              // Unknown role - show error
              SnackBars.showErrorSnackBar(
                context,
                'Your account does not have the required permissions to access this application. Please contact your administrator.',
              );
            }
          } else if (state is LoginSuccessClockInTooFar) {
            // Driver logged in but clock-in failed (too far from outlet).
            // Provide DriverMenuBloc so app bar overflow menu (profile/logout) works.
            if (!context.mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider<DriverMenuBloc>(
                  create: (_) => DriverMenuBloc(),
                  child: BlocListener<DriverMenuBloc, DriverMenuState>(
                    listener: (ctx, menuState) {
                      if (menuState is DriverMenuLogoutSuccess) {
                        SnackBars.showSuccessSnackBar(
                            ctx, menuState.response.message);
                        Navigator.of(ctx).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (__) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                        ctx.read<DriverMenuBloc>().add(const DriverMenuReset());
                      } else if (menuState is DriverMenuLogoutFailure) {
                        SnackBars.showErrorSnackBar(ctx, menuState.message);
                        Navigator.of(ctx).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (__) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                        ctx.read<DriverMenuBloc>().add(const DriverMenuReset());
                      } else if (menuState is DriverMenuAction) {
                        switch (menuState.action) {
                          case DriverMenuActionType.profile:
                            Navigator.of(ctx).push(
                              MaterialPageRoute(
                                builder: (__) => const ProfileScreen(),
                              ),
                            );
                            ctx
                                .read<DriverMenuBloc>()
                                .add(const DriverMenuReset());
                            break;
                          case DriverMenuActionType.guidelines:
                            Navigator.of(ctx).push(
                              MaterialPageRoute(
                                builder: (__) => const GuidelinesScreen(),
                              ),
                            );
                            ctx
                                .read<DriverMenuBloc>()
                                .add(const DriverMenuReset());
                            break;
                          case DriverMenuActionType.help:
                            Navigator.of(ctx).push(
                              MaterialPageRoute(
                                builder: (__) => const HelpScreen(),
                              ),
                            );
                            ctx
                                .read<DriverMenuBloc>()
                                .add(const DriverMenuReset());
                            break;
                          case DriverMenuActionType.logout:
                            break;
                        }
                      }
                    },
                    child: ClockInTooFarScreen(message: state.message),
                  ),
                ),
              ),
            );
          } else if (state is LoginFailure) {
            final t = context.read<AppTranslationsNotifier>();
            String displayMessage = state.message;
            if (state.message == TextConstants.validationPhoneRequired) {
              displayMessage = t.get(TextConstants.validationPhoneRequired);
            } else if (state.message ==
                TextConstants.validationPasswordRequired) {
              displayMessage = t.get(TextConstants.validationPasswordRequired);
            }
            SnackBars.showErrorSnackBar(context, displayMessage);
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
