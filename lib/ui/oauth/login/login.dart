import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_event.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/login/login_event.dart';
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
import 'package:niloufer_valet_mobile/ui/common/widgets/outlet_selection_dialog.dart';
import 'package:niloufer_valet_mobile/bloc/scanner/scanner_menu/scanner_menu_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/scanner/scanner_menu/scanner_menu_event.dart';
import 'package:niloufer_valet_mobile/bloc/scanner/scanner_menu/scanner_menu_state.dart';
import 'package:niloufer_valet_mobile/models/oauth/profile.dart';

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

  bool _outletDialogShowing = false;

  @override
  void dispose() {
    _loginIdController.dispose();
    _pinController.dispose();
    _loginIdFocusNode.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _showOutletDialog(
    BuildContext context,
    LoginSuccessNeedsOutletSelection state,
  ) {
    if (_outletDialogShowing) return;
    _outletDialogShowing = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<LoginBloc>(),
          // BlocBuilder updates the loading spinner inside the dialog.
          // Navigation and full dismissal are handled by the outer BlocListener
          // via pushAndRemoveUntil, which clears the entire stack including the
          // dialog route — so we do NOT pop() from here.
          child: BlocBuilder<LoginBloc, LoginState>(
            builder: (ctx, s) {
              final isLoading = s is LoginOutletSelectionLoading;
              return OutletSelectionDialog(
                outlets: state.outlets,
                isLoading: isLoading,
                onOutletSelected: isLoading
                    ? (_) {}
                    : (outlet) {
                        ctx.read<LoginBloc>().add(OutletSelected(outlet));
                      },
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      _outletDialogShowing = false;
    });
  }

  bool _profileHasScannerRole(Profile profile) {
    return profile.roles.any((r) => r.toLowerCase().contains('scanner'));
  }

  /// Driver or operator/admin: same overflow menu as driver too-far; operator help/guidelines when [operatorStyleMenus].
  Widget _driverTooFarWithMenu({
    required String message,
    required bool operatorStyleMenus,
  }) {
    return BlocProvider<DriverMenuBloc>(
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
                ctx.read<DriverMenuBloc>().add(const DriverMenuReset());
                break;
              case DriverMenuActionType.guidelines:
                Navigator.of(ctx).push(
                  MaterialPageRoute(
                    builder: (__) => GuidelinesScreen(
                      isOperatorGuidelines: operatorStyleMenus,
                    ),
                  ),
                );
                ctx.read<DriverMenuBloc>().add(const DriverMenuReset());
                break;
              case DriverMenuActionType.help:
                Navigator.of(ctx).push(
                  MaterialPageRoute(
                    builder: (__) => HelpScreen(
                      isFromOperator: operatorStyleMenus,
                    ),
                  ),
                );
                ctx.read<DriverMenuBloc>().add(const DriverMenuReset());
                break;
              case DriverMenuActionType.logout:
                break;
            }
          }
        },
        child: ClockInTooFarScreen(message: message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseMessagingService = Provider.of<FirebaseMessagingService>(
      context,
      listen: false,
    );

    final webSocketBloc = context.read<WebSocketBloc>();

    return BlocProvider(
      create: (context) => LoginBloc(
        firebaseMessagingService: firebaseMessagingService,
        webSocketBloc: webSocketBloc,
      ),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccessNeedsOutletSelection) {
            _showOutletDialog(context, state);
          } else if (state is LoginSuccess) {
            final roles =
                state.profile.roles.map((r) => r.toLowerCase()).toList();

            // pushAndRemoveUntil clears ALL routes (including any open dialog)
            // before pushing the destination. This prevents the dialog's own
            // pop() from popping the freshly pushed screen.
            if (roles.any((r) => r.contains('scanner'))) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const ScannerHomeScreen(),
                ),
                (route) => false,
              );
            } else if (roles
                .any((r) => r.contains('operator') || r.contains('admin'))) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const OperatorDashboardScreen(),
                ),
                (route) => false,
              );
            } else if (roles.any((r) => r.contains('driver'))) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const DriverHomeScreen(),
                ),
                (route) => false,
              );
              context.read<DriverStatusBloc>().add(const DriverStatusStarted());
            } else {
              SnackBars.showErrorSnackBar(
                context,
                'Your account does not have the required permissions to access this application. Please contact your administrator.',
              );
            }
          } else if (state is LoginSuccessClockInTooFar) {
            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => _driverTooFarWithMenu(
                  message: state.message,
                  operatorStyleMenus: false,
                ),
              ),
              (route) => false,
            );
          } else if (state is LoginSuccessLocationTooFar) {
            if (!context.mounted) return;
            final profile = state.profile;
            final useScannerShell = _profileHasScannerRole(profile);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => useScannerShell
                    ? BlocProvider<ScannerMenuBloc>(
                        create: (_) => ScannerMenuBloc(),
                        child: BlocListener<ScannerMenuBloc, ScannerMenuState>(
                          listener: (ctx, menuState) {
                            if (menuState is ScannerMenuLogoutSuccess) {
                              SnackBars.showSuccessSnackBar(
                                  ctx, menuState.response.message);
                              Navigator.of(ctx).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (__) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                              ctx
                                  .read<ScannerMenuBloc>()
                                  .add(const ScannerMenuReset());
                            } else if (menuState is ScannerMenuLogoutFailure) {
                              SnackBars.showErrorSnackBar(
                                  ctx, menuState.message);
                              Navigator.of(ctx).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (__) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                              ctx
                                  .read<ScannerMenuBloc>()
                                  .add(const ScannerMenuReset());
                            } else if (menuState is ScannerMenuAction) {
                              if (menuState.action ==
                                  ScannerMenuActionType.profile) {
                                Navigator.of(ctx).push(
                                  MaterialPageRoute(
                                    builder: (__) => const ProfileScreen(),
                                  ),
                                );
                                ctx
                                    .read<ScannerMenuBloc>()
                                    .add(const ScannerMenuReset());
                              }
                            }
                          },
                          child: ClockInTooFarScreen(
                            scannerMode: true,
                            message: state.userFacingMessage,
                          ),
                        ),
                      )
                    : _driverTooFarWithMenu(
                        message: state.userFacingMessage,
                        operatorStyleMenus: true,
                      ),
              ),
              (route) => false,
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
            backgroundColor: AppColors.white,
            appBar: const CustomAppBar(),
            body: SafeArea(
              child: Column(
                children: [
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
