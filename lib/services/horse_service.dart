import 'dart:convert';
import 'dart:io';
import 'package:equus/models/client.dart';
import 'package:http/http.dart' as http;
import 'package:equus/models/horse.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import secure storage

class HorseService {
  static const String _baseUrl = 'http://10.0.2.2:9090';
  final _storage = const FlutterSecureStorage();

  // Helper function to get headers with JWT token
  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final token = await _storage.read(key: 'jwt');
    final headers = <String, String>{};

    // Set Content-Type for JSON requests unless it's multipart
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json; charset=UTF-8';
    }
    // Add Authorization header if token exists
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<Horse>> fetchHorses() async {
    try {
      final headers = await _getHeaders(); // Get headers
      final response = await http.get(
        Uri.parse('$_baseUrl/horses'),
        headers: headers, // Add headers to the request
      );

      if (response.statusCode == 200) {
        final List<dynamic> horseJson = json.decode(response.body);
        return horseJson.map((json) => Horse.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        // Handle unauthorized access, maybe redirect to login
        print('Unauthorized access fetching horses.');
        throw Exception('Unauthorized: Please login again.');
      } else {
        // Handle other errors
        print('Failed to fetch horses: ${response.statusCode}');
        print('Response body: ${response.body}');
        // Return empty list or throw a more specific error
        return []; // Returning empty list as per original logic on error
      }
    } catch (e) {
      print("Error fetching horses: $e");
      // Rethrow or handle as appropriate for your app's flow
      throw Exception('Failed to fetch horses. Error: $e');
    }
  }

  // Made this non-static to access _getHeaders and _storage
  Future<bool> addHorse(
      String name,
      DateTime? birthDate,
      File? profilePicture,
      File? leftFront,
      File? rightFront,
      File? leftHind,
      File? rightHind) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/horse'));

      // Get headers, indicating it's a multipart request
      final headers = await _getHeaders(isMultipart: true);
      request.headers.addAll(headers); // Add headers to the request

      request.fields['name'] = name;
      if (birthDate != null) {
        request.fields['birthDate'] =
            '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';
      }

      // Helper to add file if not null
      Future<void> addFile(String fieldName, File? file) async {
        if (file != null) {
          request.files
              .add(await http.MultipartFile.fromPath(fieldName, file.path));
        }
      }

      await addFile('profilePicture', profilePicture);
      await addFile('pictureLeftFront', leftFront);
      await addFile('pictureRightFront', rightFront);
      await addFile('pictureLeftHind', leftHind);
      await addFile('pictureRightHind', rightHind);

      var response = await request.send();
      var responseBody = await response.stream
          .bytesToString(); // Read body for potential error messages

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Failed to add horse: ${response.statusCode}');
        print('Response body: $responseBody');
        // Consider throwing an exception with the message from responseBody if available
        return false;
      }
    } catch (e) {
      print("Error adding horse: $e");
      return false;
    }
  }

  Future<Horse> fetchHorse(int horseId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/horse/$horseId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Horse.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        print('Unauthorized access fetching horse $horseId.');
        throw Exception('Unauthorized: Please login again.');
      } else {
        print('Failed to fetch horse $horseId: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to fetch horse data');
      }
    } catch (e) {
      print("Error fetching horse $horseId: $e");
      throw Exception('Failed to fetch horse data. Error: $e');
    }
  }

  Future<List<Client>> fetchHorseClients(int horseId) async {
    try {
      final headers = await _getHeaders(); // Get headers
      final response = await http.get(
        // Ensure endpoint is correct, maybe /horses/$horseId/clients ?
        Uri.parse('$_baseUrl/horse/$horseId/clients'),
        headers: headers, // Add headers
      );

      if (response.statusCode == 200) {
        final List<dynamic> clientsJson = json.decode(response.body);
        return clientsJson.map((json) => Client.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        print('Unauthorized access fetching clients for horse $horseId.');
        throw Exception('Unauthorized: Please login again.');
      } else {
        print(
            'Failed to fetch clients for horse $horseId: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to fetch horse clients');
      }
    } catch (e) {
      print("Error fetching clients for horse $horseId: $e");
      throw Exception('Failed to fetch horse clients. Error: $e');
    }
  }

  // Made this non-static to access _getHeaders
  Future<String> uploadHorsePhoto(int horseId, File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$_baseUrl/horse/$horseId'),
      );

      // Get headers, indicating it's a multipart request
      final headers = await _getHeaders(isMultipart: true);
      request.headers.addAll(headers); // Add headers

      request.files.add(
          await http.MultipartFile.fromPath('profilePicture', imageFile.path));
      // No need to set Content-Type manually here, http.MultipartRequest handles it.

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseData);
        // Make sure the key 'profilePicturePath' matches your API response
        return jsonResponse['profilePicturePath'] ??
            ''; // Handle potential null
      } else if (response.statusCode == 401) {
        print('Unauthorized access uploading photo for horse $horseId.');
        throw Exception('Unauthorized: Please login again.');
      } else {
        print(
            'Failed to upload photo for horse $horseId: ${response.statusCode}');
        print('Response body: $responseData');
        throw Exception('Failed to upload horse photo');
      }
    } catch (e) {
      print("Error uploading photo for horse $horseId: $e");
      throw Exception('Failed to upload horse photo. Error: $e');
    }
  }
}
