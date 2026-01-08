import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:niloufer_valet_mobile/bloc/splash/splash_bloc.dart';
import 'package:niloufer_valet_mobile/bloc/websocket/websocket_bloc.dart';
import 'package:niloufer_valet_mobile/services/oauth/token_interceptor.dart';
import 'package:niloufer_valet_mobile/ui/oauth/splash/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await TokenStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        title: dotenv.env['APP_NAME'] ?? 'Niloufer Valet',
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
