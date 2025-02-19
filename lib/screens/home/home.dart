import 'package:equus/screens/home/home_page.dart';
import 'package:equus/screens/horses/horses_list.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  String _getAppBarTitle([int? requiredPage]) {
    int index = requiredPage ??
        _selectedIndex; // Use requiredPage if provided, otherwise _selectedIndex
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Horses';
      case 2:
        return 'Owners';
      case 3:
        return 'Profile';
      default:
        return 'App';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
        ),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomePage(),
          HorsesList(),
          //OwnersPage(),
          //ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        //o widget da Bottom Navigation bar
        showSelectedLabels: true,
        showUnselectedLabels: true,
        enableFeedback: true,
        currentIndex: _selectedIndex,
        onTap:
            _onItemTapped, //isto referencia uma função. Quando um item na BottomNavigationBar é clicado, o widget BottomNavigationBar sabe qual a função chamar e adicona-lhe automaticamente o argumento da função
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: _getAppBarTitle(0),
            backgroundColor: Colors.blue[800],
          ),
          BottomNavigationBarItem(
            icon: const ImageIcon(AssetImage('assets/icons/horse_icon.png')),
            label: _getAppBarTitle(1),
            backgroundColor: Colors.blue[800],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: _getAppBarTitle(2),
            backgroundColor: Colors.blue[800],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: _getAppBarTitle(3),
            backgroundColor: Colors.blue[800],
          ),
        ],
      ),
    );
  }
}
