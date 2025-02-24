import 'package:flutter/material.dart';
import 'package:equus/screens/home/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iEquus App',
      theme: ThemeData(
        primaryColor: Colors.blue[800],
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color.fromARGB(255, 21, 101, 192),
          onPrimary: Color.fromARGB(255, 255, 255, 255),
          secondary: Color.fromARGB(255, 21, 101, 192),
          onSecondary: Color.fromARGB(255, 255, 255, 255),
          error: Color.fromARGB(255, 21, 101, 192),
          onError: Color.fromARGB(255, 192, 21, 21),
          surface: Color.fromARGB(255, 255, 255, 255),
          onSurface: Color.fromARGB(255, 21, 101, 192),
        ),
      ),
      home: const Home(),
    );
  }
}
