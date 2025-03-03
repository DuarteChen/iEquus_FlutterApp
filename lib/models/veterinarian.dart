import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:equus/models/human.dart';

class Veterinarian extends Human {
  String idCedulaProfissional;

  Veterinarian({
    required super.name,
    super.email,
    super.phoneNumber,
    super.phoneCountryCode,
    required this.idCedulaProfissional,
    required super.idHuman,
  });

  // Static factory method for asynchronous initialization
  static Future<Veterinarian?> fromId(int id) async {
    final url = Uri.parse('http://127.0.0.1:9090/veterinarian/$id');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Veterinarian.fromMap(data);
      } else {
        print('Failed to load veterinarian: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching veterinarian: $e');
      return null;
    }
  }

  factory Veterinarian.fromMap(Map<String, dynamic> map) {
    return Veterinarian(
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      phoneCountryCode: map['phoneCountryCode'],
      idCedulaProfissional: map['idCedulaProfissional'],
      idHuman: map['idHuman'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['idCedulaProfissional'] = idCedulaProfissional;
    return map;
  }
}
