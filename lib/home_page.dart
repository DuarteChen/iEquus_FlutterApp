import 'package:flutter/material.dart';

class HomePageEquus extends StatefulWidget {
  const HomePageEquus({super.key});

  @override
  State<HomePageEquus> createState() => _HomePageEquusState();
}

class _HomePageEquusState extends State<HomePageEquus> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Text('Home Page',
        style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
    Text('Horses List',
        style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
    Text('Owners List',
        style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
    Text('Account Page',
        style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('I-Equus')),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.blue[800],
          ),
          BottomNavigationBarItem(
            icon: const ImageIcon(AssetImage('assets/icons/horse_icon.png')),
            label: 'Horses',
            backgroundColor: Colors.blue[800],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: 'Owners',
            backgroundColor: Colors.blue[800],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.blue[800],
          ),
        ],
      ),
    );
  }
}
