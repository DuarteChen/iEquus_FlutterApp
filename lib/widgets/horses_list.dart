import 'package:equus/models/horse.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    futureHorses = fetchHorses();
  }

  Future<List<Horse>> fetchHorses() async {
    final response = await http.get(Uri.parse('http://localhost:9090/horses'));

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
        title: Text('Lista de Cavalos'),
      ),
      body: FutureBuilder<List<Horse>>(
        future: futureHorses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Enquanto a future não se completa, mostra um indicador de carregamento
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Se houver um erro, exibe uma mensagem
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // Se os dados foram recebidos com sucesso, exibe a lista
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
                    subtitle: Text('Nascimento: ${horse.birthDate}'),
                    onTap: () {
                      // Aqui você pode navegar para uma tela de detalhes do cavalo
                    },
                  ),
                );
              },
            );
          } else {
            // Caso não tenha dados (lista vazia)
            return Center(child: Text('Nenhum cavalo encontrado.'));
          }
        },
      ),
    );
  }
}
