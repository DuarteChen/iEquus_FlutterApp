import 'package:equus/providers/horse_provider.dart';
import 'package:equus/providers/login_provider.dart';
import 'package:equus/providers/veterinarian_provider.dart';
import 'package:equus/screens/home/home.dart';
import 'package:equus/screens/login/login_screen.dart';
import 'package:equus/screens/splash/splash_screen.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  // Use runZonedGuarded to catch all unhandled errors
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => HorseProvider()),
          ChangeNotifierProvider(create: (_) => VeterinarianProvider()),
          ChangeNotifierProvider(create: (_) => LoginProvider()),
        ],
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Caught unhandled error: $error');
    debugPrint(stack.toString());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iEquus App',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 46, 95, 138),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color.fromARGB(255, 46, 95, 138),
          onPrimary: Color.fromARGB(255, 255, 255, 255),
          secondary: Color.fromARGB(255, 226, 240, 253),
          onSecondary: Color.fromARGB(255, 46, 95, 138),
          error: Color.fromARGB(255, 46, 95, 138),
          onError: Color.fromARGB(255, 255, 255, 255),
          surface: Color.fromARGB(255, 255, 255, 255),
          onSurface: Color.fromARGB(255, 46, 95, 138),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const Home(),
      },
    );
  }
}
