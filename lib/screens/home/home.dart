import 'package:equus/screens/home/home_page.dart';
import 'package:equus/screens/horses/horses_list_screen.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _BottomNavItem {
  final Widget page;
  final String title;
  final Widget icon;

  const _BottomNavItem(
      {required this.page, required this.title, required this.icon});
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static final List<_BottomNavItem> _navItems = [
    _BottomNavItem(
      page: const HomePage(),
      title: 'Home',
      icon: const Icon(Icons.home),
    ),
    _BottomNavItem(
      page: const HorsesListScreen(),
      title: 'Horses',
      icon: const ImageIcon(AssetImage('assets/icons/horse_icon.png')),
    ),
    _BottomNavItem(
      page: const Center(
          child: Text("Owners Page (Not Implemented)")), // Placeholder
      title: 'Owners',
      icon: const Icon(Icons.people),
    ),
    _BottomNavItem(
      page: const Center(
          child: Text("Profile Page (Not Implemented)")), // Placeholder
      title: 'Profile',
      icon: const Icon(Icons.person),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _navItems.map((item) => item.page).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: true,
        enableFeedback: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Theme.of(context).colorScheme.onPrimary,
        unselectedItemColor:
            Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
        items: _navItems.map((item) {
          return BottomNavigationBarItem(
            icon: item.icon,
            label: item.title,
          );
        }).toList(),
      ),
    );
  }
}
