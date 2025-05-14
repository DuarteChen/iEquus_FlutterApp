import 'dart:convert';
import 'package:equus/models/appointment.dart';
import 'package:equus/models/hospital.dart';
import 'package:http/http.dart' as http;
import 'package:equus/models/human.dart';

class Veterinarian extends Human {
  String idCedulaProfissional;
  Hospital hospital;
  final List<Appointment> appointments = [];

  Veterinarian({
    required super.name,
    super.email,
    super.phoneNumber,
    super.phoneCountryCode,
    required this.idCedulaProfissional,
    required super.idHuman,
    required this.hospital,
  });

  static Future<Veterinarian?> fromId(String token) async {
    final url = Uri.parse('http://10.0.2.2:9090/veterinarian');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

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

  Future<Veterinarian?> appointmentsFromId(String token) async {
    final url =
        Uri.parse('http://10.0.2.2:9090/appointments/veterinarian/$idHuman');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

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
      idHuman: map['idVeterinary'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      phoneCountryCode: map['phoneCountryCode'],
      idCedulaProfissional: map['idCedulaProfissional'],
      hospital: Hospital.fromMap(map['hospital']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['idCedulaProfissional'] = idCedulaProfissional;
    map['hospital'] = hospital.toMap();
    return map;
  }
}
