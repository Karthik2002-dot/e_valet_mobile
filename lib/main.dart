import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:niloufer_valet_mobile/bloc/splash/splash_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/websocket/websocket_bloc.dart';
import 'package:niloufer_valet_mobile/services/notification/firebase_messaging_service.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/ui/oauth/splash/splash.dart';

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
    return MultiBlocProvider(
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
      ],
      child: MaterialApp(
        title: dotenv.env['APP_NAME'] ?? 'Cafe Niloufer E-Valet',
        navigatorKey: FirebaseMessagingService.navigatorKey,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
