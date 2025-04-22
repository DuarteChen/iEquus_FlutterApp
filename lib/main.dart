import 'package:equus/providers/horse_provider.dart';
import 'package:equus/providers/veterinarian_provider.dart';
import 'package:equus/screens/home/home.dart';
import 'package:equus/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'jwt');

    final String initialRoute = token != null ? '/home' : '/login';
    debugPrint("Token found: ${token != null}, Initial Route: $initialRoute");

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => HorseProvider()),
          ChangeNotifierProvider(create: (_) => VeterinarianProvider()),
        ],
        child: MyApp(initialRoute: initialRoute),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    if (initialRoute == '/home') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<VeterinarianProvider>(context, listen: false)
            .loadVeterinarianData();
        Provider.of<HorseProvider>(context, listen: false).loadHorses();
      });
    }
    // -------------------------------------------------------

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
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const Home(),
      },
      // --- Add these lines ---
      localizationsDelegates: const [
        AppLocalizations.delegate, // Your app's specific translations
        GlobalMaterialLocalizations.delegate, // Built-in Material localizations
        GlobalWidgetsLocalizations
            .delegate, // Built-in Widget localizations (text direction, etc.)
        GlobalCupertinoLocalizations
            .delegate, // Built-in Cupertino localizations
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('pt'),
      ],
      home: initialRoute == '/home' ? InitialLoadingScreen() : LoginScreen(),
    );
  }
}

class InitialLoadingScreen extends StatelessWidget {
  const InitialLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
