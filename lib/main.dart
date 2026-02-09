import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:niloufer_valet_mobile/bloc/driver/driver_status/driver_status_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/splash/splash_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/websocket/websocket_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/websocket/websocket_event.dart';
import 'package:niloufer_valet_mobile/services/notification/firebase_messaging_service.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/ui/common/connectivity_wrapper.dart';
import 'package:niloufer_valet_mobile/ui/oauth/splash/splash.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await TokenStorage.init();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Firebase Messaging Service
  final firebaseMessagingService = FirebaseMessagingService();
  await firebaseMessagingService.initialize();

  runApp(MyApp(firebaseMessagingService: firebaseMessagingService));
}

class MyApp extends StatelessWidget {
  final FirebaseMessagingService firebaseMessagingService;

  const MyApp({super.key, required this.firebaseMessagingService});

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      child: MultiProvider(
        providers: [
          // Provide FirebaseMessagingService to the entire app
          Provider<FirebaseMessagingService>.value(
            value: firebaseMessagingService,
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<WebSocketBloc>(
              create: (context) => WebSocketBloc(),
              lazy: false,
            ),
            BlocProvider<SplashBloc>(
              create: (context) => SplashBloc(
                webSocketBloc: context.read<WebSocketBloc>(),
              ),
            ),
            BlocProvider<DriverStatusBloc>(
              create: (context) => DriverStatusBloc(),
            ),
          ],
          child: MaterialApp(
            title: dotenv.env['APP_NAME'] ?? 'Cafe Niloufer E-Valet',
            navigatorKey: FirebaseMessagingService.navigatorKey,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    );
  }
}

/// Listens to app lifecycle and triggers WebSocket reconnect when app
/// returns from background (e.g. user opens app from push notification).
class _AppLifecycleHandler extends StatefulWidget {
  final Widget child;

  const _AppLifecycleHandler({required this.child});

  @override
  State<_AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<_AppLifecycleHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      try {
        context.read<WebSocketBloc>().add(const ReconnectWebSocket());
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
