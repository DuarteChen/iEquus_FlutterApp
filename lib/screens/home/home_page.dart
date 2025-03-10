import 'package:equus/screens/appointment/create_measure_screen.dart';
import 'package:equus/screens/appointment/horse_selector.dart';
import 'package:equus/screens/horses/create_horse_screen.dart';
import 'package:equus/widgets/main_button_blue.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 8),
                  child: Text(
                    "Medical Services",
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
                        MaterialPageRoute(
                            builder: (context) => CreateHorseScreen()),
                      );
                    }),
                SizedBox(height: 8),
                MainButtonBlue(
                  iconImage: 'assets/icons/appointment_new_black.png',
                  buttonText: "New Measure",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HorseSelector(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 8),
                MainButtonBlue(
                    iconImage: 'assets/icons/client_new_black.png',
                    buttonText: "New Client",
                    onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
