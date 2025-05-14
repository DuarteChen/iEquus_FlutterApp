import 'package:equus/models/veterinarian.dart';
import 'package:equus/providers/veterinarian_provider.dart';
import 'package:equus/screens/appointment/horse_selector.dart';
import 'package:equus/screens/horses/create_horse_screen.dart';
import 'package:equus/widgets/main_button_blue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final storage = const FlutterSecureStorage();

  Future<void> _logout() async {
    await storage.delete(key: 'jwt');

    if (mounted) {
      Provider.of<VeterinarianProvider>(context, listen: false).clear();

      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("iEquus"),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                welcomeContainer(),
                SizedBox(height: 8),
                appointmentsSection(),
                SizedBox(height: 8),
                servicesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget servicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8),
          child: Text(
            "Services",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        MainButtonBlue(
            iconImage: 'assets/icons/horse_new_black.png',
            buttonText: "New Horse",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateHorseScreen()),
              );
            }),
        SizedBox(height: 8),
        MainButtonBlue(
            iconImage: 'assets/icons/client_new_black.png',
            buttonText: "New Client",
            onTap: () {}),
      ],
    );
  }

  Widget appointmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
              child: Text(
                "Appointments",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HorseSelector(selectorType: 'appointment'),
                  ),
                );
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 8),
            Expanded(
              child: MainButtonBlue(
                icon: Icon(Icons.stream),
                buttonText: "Measure",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HorseSelector(selectorType: 'measure'),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: MainButtonBlue(
                icon: Icon(Icons.medication_outlined),
                buttonText: "X-Ray",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HorseSelector(selectorType: 'x-ray'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Consumer<VeterinarianProvider> welcomeContainer() {
    return Consumer<VeterinarianProvider>(
      builder: (context, vetProvider, child) {
        final Veterinarian? veterinarian = vetProvider.veterinarian;
        final String nameText = veterinarian?.name ?? 'Loading...';
        final String cedulaText = veterinarian?.idCedulaProfissional ?? '---';

        // Determine the widget to display for the hospital logo/placeholder
        Widget? hospitalLogoWidget;
        if (veterinarian != null &&
            veterinarian.hasHospital &&
            veterinarian.hospital!.logoPath != null &&
            veterinarian.hospital!.logoPath!.isNotEmpty) {
          hospitalLogoWidget = ClipRRect(
            borderRadius: BorderRadius.circular(8.0), // Add rounded corners
            child: Image.network(
              veterinarian.hospital!.logoPath!,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          );
        } else {
          hospitalLogoWidget = SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome,',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nameText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cedulaText,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              hospitalLogoWidget,
            ],
          ),
        );
      },
    );
  }
}
