import 'package:equus/models/horse.dart';
import 'package:equus/screens/horses/horse_profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class HorsesList extends StatefulWidget {
  const HorsesList({super.key});

  @override
  State<HorsesList> createState() {
    return _HorsesListState();
  }
}

class _HorsesListState extends State<HorsesList> {
  late Future<List<Horse>> futureHorses;
  List<Horse> _allHorses = [];
  List<Horse> _filteredHorses = [];

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureHorses = _fetchHorses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

//TODO - check if this is working?
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshHorses();
  }

  Future<void> _refreshHorses() async {
    final horses = await _fetchHorses();
    _allHorses = horses;
    _filterHorsesList(_searchQuery);
  }

  void _filterHorsesList(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredHorses = _allHorses;
      } else {
        _filteredHorses = _allHorses
            .where((horse) =>
                horse.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      futureHorses = Future.value(_filteredHorses);
    });
  }

  Future<List<Horse>> _fetchHorses() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:9090/horses'));
    if (response.statusCode == 200) {
      final List<dynamic> horseJson = json.decode(response.body);
      return horseJson.map((json) => Horse.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar os cavalos');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search...',
                  icon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _filterHorsesList('');
                    },
                  ),
                ),
                onChanged: (textToSearch) {
                  _filterHorsesList(textToSearch);
                },
                controller: _searchController,
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
        onRefresh: _refreshHorses,
        child: FutureBuilder<List<Horse>>(
          future: futureHorses,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro'));
            } else if (snapshot.hasData) {
              final horses = snapshot.data!;
              return ListView.builder(
                itemCount: horses.length,
                itemBuilder: (context, index) {
                  final horse = horses[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color.fromARGB(255, 226, 226, 226),
                        child: horse.profilePicturePath != null
                            ? ClipOval(
                                child: Image.network(
                                  horse.profilePicturePath!,
                                  width: 40, // Adjust size as needed
                                  height: 40, // Adjust size as needed
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                'assets/images/horse_empty_profile_image.png',
                                width: 40, // Adjust size as needed
                                height: 40, // Adjust size as needed
                                fit: BoxFit.cover,
                              ),
                      ),
                      title: Text(horse.name),
                      subtitle: Text(
                        horse.birthDate != null
                            ? DateFormat('dd-MM-yyyy').format(horse.birthDate!)
                            : 'No birth date',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HorseProfile(
                              horse: horse,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('Nenhum cavalo encontrado.'));
            }
          },
        ),
      ),
    );
  }
}
