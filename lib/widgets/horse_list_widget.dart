import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:equus/providers/horse_provider.dart';

import 'package:cached_network_image/cached_network_image.dart';
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
            // Assuming HorseProvider has an 'isLoading' boolean property.
            // This helps distinguish initial loading from an empty list after loading.
            ? (horseProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : const Center(child: Text("No horses registered")))
            : _buildHorseList(horseProvider),
      ),
    );
  }

  Widget _buildHorseList(HorseProvider horseProvider) {
    return ListView.builder(
      itemCount: horseProvider.horses.length,
      itemBuilder: (context, index) {
        final horse = horseProvider.horses[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color.fromARGB(255, 226, 226, 226),
              // Check if profilePicturePath is not null and not empty
              child: (horse.profilePicturePath != null &&
                      horse.profilePicturePath!.isNotEmpty)
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: horse.profilePicturePath!,
                        imageBuilder: (context, imageProvider) => Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(strokeWidth: 2.0),
                        errorWidget: (context, url, error) =>
                            _defaultHorseImage(), // Fallback on error
                      ),
                    )
                  : _defaultHorseImage(), // Fallback if no path
            ),
            title: Text(horse.name),
            subtitle: Text(horse.birthDateToString() ?? 'No birth date'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => widget.widgetForSelectedScreen(horse),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _defaultHorseImage() {
    return ClipOval(
      child: Image.asset(
        'assets/images/horse_empty_profile_image.png', // Ensure this asset exists
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      ),
    );
  }
}
