import 'package:equus/models/horse.dart';
import 'package:equus/widgets/horse_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:equus/providers/horse_provider.dart';
import 'package:equus/screens/horses/horse_profile.dart';

class HorsesListScreen extends StatefulWidget {
  const HorsesListScreen({super.key});

  @override
  State<HorsesListScreen> createState() => _HorsesListScreenState();
}

class _HorsesListScreenState extends State<HorsesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HorsesListWidget(
      widgetForSelectedScreen: (selectedHorse) {
        return HorseProfile(horse: selectedHorse);
      },
    );
  }
}
