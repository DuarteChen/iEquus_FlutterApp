import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(Icons.add_box_rounded),
      label: Text("Create New Horse"),
    ); //Text('iEquus HomePage v2', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold));
  }
}
