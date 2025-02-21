import 'package:equus/models/horse.dart';
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

  @override
  void initState() {
    super.initState();
    futureHorses = _fetchHorses();
  }

  // Refresh function when user pulls down to refresh
  Future<void> _refreshHorses() async {
    setState(() {
      futureHorses = _fetchHorses(); // Reload the list by fetching horses again
    });
  }

  // Fetch horses from the server
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
    return RefreshIndicator(
      onRefresh: _refreshHorses, // Called when user pulls down to refresh
      child: FutureBuilder<List<Horse>>(
        future: futureHorses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final horses = snapshot.data!;
            return ListView.builder(
              itemCount: horses.length,
              itemBuilder: (context, index) {
                final horse = horses[index];
                return Card(
                    child: ListTile(
                  leading: horse.profilePicturePath != null
                      ? Image.network(horse.profilePicturePath!)
                      : Icon(Icons.image_not_supported),
                  title: Text(horse.name),
                  subtitle: Text(
                    horse.birthDate != null
                        ? DateFormat('dd-MM-yyyy')
                            .format(horse.birthDate!) // Format the DateTime
                        : 'No birth date',
                  ),
                  onTap: () {
                    // TODO - Ecrã de detalhes do cavalo
                  },
                ));
              },
            );
          } else {
            return Center(child: Text('Nenhum cavalo encontrado.'));
          }
        },
      ),
    );
  }
}
