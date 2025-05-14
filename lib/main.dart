import 'package:equus/providers/horse_provider.dart';
import 'package:equus/providers/login_provider.dart';
import 'package:equus/providers/veterinarian_provider.dart';
import 'package:equus/screens/home/home.dart';
import 'package:equus/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) async {
    const storage = FlutterSecureStorage();
    //storage.deleteAll(); //To clean the JWT Token

    String? token = await storage.read(key: 'jwt');

    final String initialRoute = token != null ? '/home' : '/login';
    debugPrint("Token found: ${token != null}, Initial Route: $initialRoute");

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => HorseProvider()),
          ChangeNotifierProvider(create: (_) => VeterinarianProvider()),
          ChangeNotifierProvider(create: (_) => LoginProvider()),
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
    Widget homeScreenWidget;

    if (initialRoute == '/home') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<VeterinarianProvider>(context, listen: false)
            .loadVeterinarianData();
        Provider.of<HorseProvider>(context, listen: false).loadHorses();
      });
      homeScreenWidget = const Home();
    } else {
      homeScreenWidget = const LoginScreen();
    }

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
      // Set the home widget directly. This makes it the root of the navigation stack.
      home: homeScreenWidget,
      // The 'routes' map is still used for Navigator.pushNamed operations.
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const Home(),
      },
      supportedLocales: const [
        Locale('en'),
        Locale('pt'),
      ],
    );
  }
}
