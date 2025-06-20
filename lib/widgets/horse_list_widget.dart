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
        onRefresh: horseProvider.loadHorses,
        child: horseProvider.horses.isEmpty
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
        return Dismissible(
          key: ValueKey(horse.idHorse), // Unique key for each item
          direction:
              DismissDirection.endToStart, // Allow swipe from right to left
          // Show confirmation dialog before dismissing
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Confirm Deletion"),
                  content: Text(
                      "Are you sure you want to delete ${horse.name}? This action cannot be undone."),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pop(false), // Dismiss and return false (cancel)
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pop(true), // Dismiss and return true (confirm)
                      child: const Text("Delete"),
                    ),
                  ],
                );
              },
            );
          },
          // Perform deletion if confirmed
          onDismissed: (direction) async {
            // The item is already visually removed by Dismissible at this point.
            // We perform the actual deletion and handle feedback.
            try {
              await Provider.of<HorseProvider>(context, listen: false)
                  .deleteHorse(horse.idHorse);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${horse.name} deleted successfully!')),
              );
            } catch (error) {
              // If deletion fails, the item needs to be re-inserted visually.
              // The provider state hasn't changed, so we just need to rebuild.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Failed to delete ${horse.name}. Error: $error')),
              );
              // Rebuild the list to show the item again if deletion failed.
              if (mounted) {
                setState(() {});
              }
            }
          },
          // Background shown during swipe
          background: Container(
            color: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
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
