import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:equus/config/api_constants.dart';
import 'package:equus/models/client.dart';
import 'package:http/http.dart' as http;
import 'package:equus/models/horse.dart';

class HorseService {
  Future<List<Horse>> fetchHorses() async {
    try {
      final headers = await HttpClient().getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/horses'),
        headers: headers, // Add headers to the request
      );

      if (response.statusCode == 200) {
        final List<dynamic> horseJson = json.decode(response.body);
        return horseJson.map((json) => Horse.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        // Handle unauthorized access, maybe redirect to login
        throw Exception('Unauthorized: Please login again.');
      } else {
        // Handle other errors
        developer.log('Failed to fetch horses: ${response.statusCode}');
        // Return empty list or throw a more specific error
        return []; // Returning empty list as per original logic on error
      }
    } catch (e) {
      developer.log('Error fetching horses: $e');
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
      var request =
          http.MultipartRequest('POST', Uri.parse('$apiBaseUrl/horse'));

      // Get headers, indicating it's a multipart request
      final headers = await HttpClient().getHeaders(isMultipart: true);
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
        developer.log('Failed to fetch horses: ${response.statusCode}');
        developer.log('Response body: $responseBody');

        // Consider throwing an exception with the message from responseBody if available
        return false;
      }
    } catch (e) {
      developer.log("Error adding horse: $e");
      return false;
    }
  }

  Future<Horse> fetchHorse(int horseId) async {
    try {
      final headers = await HttpClient().getHeaders();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/horse/$horseId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Horse.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        developer.log('Unauthorized access fetching horse $horseId.');
        throw Exception('Unauthorized: Please login again.');
      } else {
        developer.log('Failed to fetch horses: ${response.statusCode}');
        developer.log('Response body: ${response.body}');
        throw Exception('Failed to fetch horse data');
      }
    } catch (e) {
      developer.log("Error fetching horse $horseId: $e");
      throw Exception('Failed to fetch horse data. Error: $e');
    }
  }

  Future<List<Client>> fetchHorseClients(int horseId) async {
    try {
      final headers = await HttpClient().getHeaders(); // Get headers
      final response = await http.get(
        // Ensure endpoint is correct, maybe /horses/$horseId/clients ?
        Uri.parse('$apiBaseUrl/horse/$horseId/clients'),
        headers: headers, // Add headers
      );

      if (response.statusCode == 200) {
        final List<dynamic> clientsJson = json.decode(response.body);
        return clientsJson.map((json) => Client.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        developer
            .log('Unauthorized access fetching clients for horse $horseId.');
        throw Exception('Unauthorized: Please login again.');
      } else {
        developer.log(
            'Failed to fetch clients for horse $horseId: ${response.statusCode}');
        developer.log('Response body: ${response.body}');
        throw Exception('Failed to fetch horse clients');
      }
    } catch (e) {
      developer.log("Error fetching clients for horse $horseId: $e");
      throw Exception('Failed to fetch horse clients. Error: $e');
    }
  }

  // Made this non-static to access _getHeaders
  Future<String> uploadHorseProfilePhoto(int horseId, File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$apiBaseUrl/horse/$horseId'),
      );

      // Get headers, indicating it's a multipart request
      final headers = await HttpClient().getHeaders(isMultipart: true);
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
        developer
            .log('Unauthorized access uploading photo for horse $horseId.');
        throw Exception('Unauthorized: Please login again.');
      } else {
        developer.log(
            'Failed to upload photo for horse $horseId: ${response.statusCode}');
        developer.log('Response body: $responseData');
        throw Exception('Failed to upload horse photo');
      }
    } catch (e) {
      developer.log("Error uploading photo for horse $horseId: $e");
      throw Exception('Failed to upload horse photo. Error: $e');
    }
  }

  // Made this non-static to access _getHeaders
  Future<String> deleteHorse(int horseId) async {
    try {
      final headers = await HttpClient().getHeaders();
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/horse/$horseId'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.statusCode == 200 && response.body.isNotEmpty) {
          // Attempt to decode JSON only if status is 200 and body is not empty
          try {
            var jsonResponse = json.decode(response.body);
            return jsonResponse['message'] ?? 'Horse deleted successfully.';
          } catch (e) {
            developer.log(
                'Successfully deleted horse $horseId but response body was not valid JSON: ${response.body}');
            return response.body.isNotEmpty
                ? response.body
                : 'Horse deleted successfully.';
          }
        }
        // For 204 No Content, or 200 with empty body
        return 'Horse deleted successfully.';
      } else if (response.statusCode == 401) {
        developer.log('Unauthorized access deleting horse $horseId.');
        throw Exception('Unauthorized: Please login again.');
      } else if (response.statusCode == 404) {
        developer.log('Horse $horseId not found for deletion.');
        throw Exception('Horse not found.');
      } else {
        String errorMessage =
            'Failed to delete horse. Status: ${response.statusCode}';
        if (response.body.isNotEmpty) {
          try {
            var errorJson = json.decode(response.body);
            errorMessage =
                errorJson['message'] ?? errorJson['error'] ?? errorMessage;
          } catch (_) {
            // Body is not JSON, use raw body if it seems like a message
            if (response.body.length < 200) {
              // Heuristic for a message
              errorMessage = response.body;
            }
          }
        }
        developer
            .log('Failed to delete horse $horseId: ${response.statusCode}');
        developer.log('Response body: ${response.body}');
        throw Exception(errorMessage);
      }
    } catch (e) {
      developer.log("Error deleting horse $horseId: $e");
      if (e is SocketException) {
        throw Exception('Network error. Please check your connection.');
      }
      if (e is http.ClientException) {
        throw Exception('Network error. Please try again.');
      }
      rethrow;
    }
  }
}
