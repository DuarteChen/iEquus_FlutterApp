import 'package:equus/providers/horse_provider.dart';
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
    // Check if there is a token
    const storage = FlutterSecureStorage();
    //await storage.delete(key: 'jwt'); // Keep commented unless debugging login
    String? token = await storage.read(key: 'jwt');

    // Determine initial route based *only* on token presence
    final String initialRoute = token != null ? '/home' : '/login';
    debugPrint("Token found: ${token != null}, Initial Route: $initialRoute");

    runApp(
      MultiProvider(
        providers: [
          // Create providers here. They start empty.
          ChangeNotifierProvider(create: (_) => HorseProvider()),
          ChangeNotifierProvider(create: (_) => VeterinarianProvider()),
        ],
        // Pass the determined initial route
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
    // --- Load initial data after providers are available ---
    // This ensures data loading starts as soon as the app runs if needed.
    if (initialRoute == '/home') {
      // Use WidgetsBinding.instance.addPostFrameCallback to run after the first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Use listen: false as this is outside the build method context for MyApp
        Provider.of<VeterinarianProvider>(context, listen: false)
            .loadVeterinarianData();
        // You might also want to load initial horses here if needed
        // Provider.of<HorseProvider>(context, listen: false).loadHorses();
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
          error: Color.fromARGB(
              255, 46, 95, 138), // Consider a distinct error color
          onError: Color.fromARGB(255, 255, 255, 255),
          surface: Color.fromARGB(255, 255, 255, 255),
          onSurface: Color.fromARGB(
              255, 46, 95, 138), // Or Colors.black for text on surface
        ),
        // You might want to define other theme properties like textTheme, appBarTheme etc.
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const Home(),
        // Define other routes if needed
      },
      // Optional: Add a splash screen or loading indicator while initial data loads
      // home: initialRoute == '/home' ? InitialLoadingScreen() : LoginScreen(),
    );
  }
}

// Optional: A simple screen to show while initial data loads
// class InitialLoadingScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(child: CircularProgressIndicator()),
//     );
//   }
// }
