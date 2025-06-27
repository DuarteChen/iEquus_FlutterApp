import 'package:equus/providers/horse_provider.dart';
import 'package:equus/providers/veterinarian_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? token;
      try {
        const storage = FlutterSecureStorage();
        token = await storage.read(key: 'jwt');
      } catch (e) {
        token = null; // Assume no token if error
      }

      if (token != null) {
        try {
          if (mounted) {
            // Access providers. listen: false is correct as we're just calling methods.
            VeterinarianProvider veterinarianProvider =
                Provider.of<VeterinarianProvider>(context, listen: false);
            HorseProvider horseProvider =
                Provider.of<HorseProvider>(context, listen: false);

            // Load data concurrently
            await Future.wait([
              veterinarianProvider.loadVeterinarianData(),
              horseProvider.loadHorses(),
            ]);
          }

          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        } catch (e) {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      } else {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
