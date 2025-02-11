import 'package:equus/screens/home_page.dart';
import 'package:equus/widgets/horses_list.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    HorsesList(),
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
      appBar: AppBar(title: const Text('iEquus')),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        //o widget da Bottom Navigation bar
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap:
            _onItemTapped, //isto referencia uma função. Quando um item na BottomNavigationBar é clicado, o widget BottomNavigationBar sabe qual a função chamar e adicona-lhe automaticamente o argumento da função
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
