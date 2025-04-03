import 'dart:convert';
import 'dart:io';
import 'package:equus/models/client.dart';
import 'package:http/http.dart' as http;
import 'package:equus/models/horse.dart';

class HorseService {
  static const String _baseUrl = 'http://10.0.2.2:9090';

  Future<List<Horse>> fetchHorses() async {
    final response = await http.get(Uri.parse('$_baseUrl/horses'));

    if (response.statusCode == 200) {
      final List<dynamic> horseJson = json.decode(response.body);
      return horseJson.map((json) => Horse.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load horses');
    }
  }

  static Future<bool> addHorse(
      String name,
      DateTime? birthDate,
      File? profilePicture,
      File? leftFront,
      File? rightFront,
      File? leftHind,
      File? rightHind) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));

      request.fields['name'] = name;
      if (birthDate != null) {
        request.fields['birthDate'] =
            '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';
      }

      if (profilePicture != null) {
        request.files.add(
            await http.MultipartFile.fromPath('photo', profilePicture.path));
      }
      if (leftFront != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'pictureLeftFront', leftFront.path));
      }
      if (rightFront != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'pictureRightFront', rightFront.path));
      }
      if (leftHind != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'pictureLeftHind', leftHind.path));
      }
      if (rightHind != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'pictureRightHind', rightHind.path));
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<Horse> fetchHorse(int horseId) async {
    final response = await http.get(Uri.parse('$_baseUrl/horses/$horseId'));

    if (response.statusCode == 200) {
      return Horse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch horse data');
    }
  }

  Future<List<Client>> fetchHorseClients(int horseId) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/horse/$horseId/clients'));

    if (response.statusCode == 200) {
      final List<dynamic> clientsJson = json.decode(response.body);
      return clientsJson.map((json) => Client.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch horse clients');
    }
  }

  Future<String> uploadHorsePhoto(int horseId, File imageFile) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('$_baseUrl/horses/$horseId'),
    );

    request.files
        .add(await http.MultipartFile.fromPath('photo', imageFile.path));
    request.headers['Content-Type'] = 'multipart/form-data';

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);
      return jsonResponse['profilePicturePath']; // Retorna a nova URL da imagem
    } else {
      throw Exception('Failed to upload horse photo');
    }
  }
}
