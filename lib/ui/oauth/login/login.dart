import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:niloufer_valet_mobile/bloc/websocket/websocket_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/login/login_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/oauth/login/login_state.dart';
import 'package:niloufer_valet_mobile/services/location/location_service.dart';
import 'package:niloufer_valet_mobile/services/notification/firebase_messaging_service.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
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

  Future<void> _requestDriverPermissions(BuildContext context) async {
    // Request Location Permission
    LocationPermission locationPermission =
        await LocationService.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await LocationService.requestPermission();
    }

    if (locationPermission != LocationPermission.denied &&
        locationPermission != LocationPermission.deniedForever) {
      // Get current location and store it
      try {
        final position = await LocationService.getCurrentLocation();
        final latitude = position.latitude;
        final longitude = position.longitude;
        final location =
            '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

        await TokenStorage.saveCurrentLocation(
          latitude: latitude,
          longitude: longitude,
          location: location,
        );
      } catch (e) {
        // Continue even if location fetch fails
      }
    }

    // Request Camera Permission
    await Permission.camera.request();

    // Navigate to driver home screen regardless of permission results
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DriverHomeScreen(),
        ),
      );
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

            // Only request permissions for drivers
            if (roles.contains('driver')) {
              _requestDriverPermissions(context);
            } else if (roles.contains('operator')) {
              // Operators go directly to dashboard without permissions
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
