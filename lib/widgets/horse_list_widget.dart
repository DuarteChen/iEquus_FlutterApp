import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:equus/providers/horse_provider.dart';
import 'package:equus/screens/horses/horse_profile.dart';

import 'package:equus/models/horse.dart';

typedef HorseWidgetBuilder = Widget Function(Horse horse);

class HorsesListWidget extends StatefulWidget {
  final HorseWidgetBuilder widgetForSelectedScreen;

  const HorsesListWidget({super.key, required this.widgetForSelectedScreen});

  @override
  State<HorsesListWidget> createState() => _HorsesListWidgetState();
}

class _HorsesListWidgetState extends State<HorsesListWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horseProvider = Provider.of<HorseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).secondaryHeaderColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Align(
              alignment: Alignment.center,
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search...',
                  icon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      horseProvider.filterHorses('');
                    },
                  ),
                ),
                onChanged: (textToSearch) {
                  horseProvider.filterHorses(textToSearch);
                },
              ),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(8),
          child: Container(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: horseProvider.refreshHorses,
        child: horseProvider.horses.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: horseProvider.horses.length,
                itemBuilder: (context, index) {
                  final horse = horseProvider.horses[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color.fromARGB(255, 226, 226, 226),
                        child: horse.profilePicturePath != null
                            ? ClipOval(
                                child: Image.network(
                                  horse.profilePicturePath!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipOval(
                                child: Image.asset(
                                  'assets/images/horse_empty_profile_image.png',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      title: Text(horse.name),
                      subtitle:
                          Text(horse.birthDateToString() ?? 'No birth date'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                widget.widgetForSelectedScreen(horse),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
