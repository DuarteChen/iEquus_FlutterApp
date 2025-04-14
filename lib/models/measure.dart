import 'dart:convert';
import 'dart:io'; // Import dart:io for File
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Measure {
  int id;
  String picturePath;
  List<Offset> coordinates;
  final DateTime date;
  final int horseId;

  int? algorithmBW;
  int? algorithmBCS;

  int? userBW;
  int? userBCS;
  bool? favorite;
  int? veterinarianId; // Keep for storing the ID after creation/fetch
  int? appointmentId;

  // --- Constructor, fromJson, toJson, converters remain the same ---
  Measure({
    required this.id,
    this.userBW,
    this.algorithmBW,
    this.userBCS,
    this.algorithmBCS,
    required this.date,
    required this.coordinates,
    required this.picturePath,
    this.favorite,
    required this.horseId,
    this.veterinarianId,
    this.appointmentId,
  });

  factory Measure.fromJson(Map<String, dynamic> json) {
    // Assuming coordinates are stored as a JSON string in the DB/API response
    List<Offset> parsedCoordinates = [];
    if (json['coordinates'] is String) {
      try {
        parsedCoordinates =
            Measure.convertJsonToOffsetsStatic(json['coordinates']);
      } catch (e) {
        debugPrint("Error parsing coordinates from JSON: $e");
        // Handle error or set default empty list
      }
    } else if (json['coordinates'] is List) {
      // Handle if API directly returns a list of maps (less likely if using convertOffsetsToJson)
      try {
        parsedCoordinates = (json['coordinates'] as List).map((point) {
          // Ensure point is a Map and keys exist, handle potential type errors
          final double? x = (point is Map && point.containsKey('x'))
              ? (point['x'] as num?)?.toDouble()
              : null;
          final double? y = (point is Map && point.containsKey('y'))
              ? (point['y'] as num?)?.toDouble()
              : null;
          if (x != null && y != null) {
            return Offset(x, y);
          } else {
            return Offset.zero;
          }
        }).toList();
      } catch (e) {
        debugPrint("Error parsing coordinates list from JSON: $e");
      }
    }

    return Measure(
      id: json['idMeasure'] ?? 0, // Provide default if null
      userBW: json['userBW'],
      algorithmBW: json['algorithmBW'],
      userBCS: json['userBCS'],
      algorithmBCS: json['algorithmBCS'],
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(), // Provide default
      coordinates: parsedCoordinates, // Use parsed coordinates
      picturePath: json['picturePath'] ?? '', // Provide default
      favorite: json['favorite'],
      horseId: json['horseId'] ?? 0, // Provide default
      veterinarianId: json['veterinarianId'],
      appointmentId: json['appointmentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeasure': id,
      'userBW': userBW,
      'algorithmBW': algorithmBW,
      'userBCS': userBCS,
      'algorithmBCS': algorithmBCS,
      'date': date.toIso8601String(),
      // Convert coordinates back to JSON string for sending
      'coordinates': convertOffsetsToJson(coordinates),
      'picturePath': picturePath,
      'favorite': favorite,
      'horseId': horseId,
      'veterinarianId': veterinarianId,
      'appointmentId': appointmentId,
    };
  }

  String convertOffsetsToJson(List<Offset> coordinates) {
    final List<Map<String, double>> mappedCoordinates =
        coordinates.map((offset) {
      return {'x': offset.dx, 'y': offset.dy};
    }).toList();
    return jsonEncode(mappedCoordinates);
  }

  // Static version for use in fromJson factory
  static List<Offset> convertJsonToOffsetsStatic(String jsonString) {
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((point) {
        // Add type checking for robustness
        if (point is Map && point.containsKey('x') && point.containsKey('y')) {
          final double? x = (point['x'] as num?)?.toDouble();
          final double? y = (point['y'] as num?)?.toDouble();
          if (x != null && y != null) {
            return Offset(x, y);
          }
        }
        // Handle invalid point format, maybe return Offset.zero or throw
        debugPrint("Invalid point format in JSON coordinates: $point");
        return Offset.zero;
      }).toList();
    } catch (e) {
      debugPrint("Error decoding JSON coordinates string: $e");
      return []; // Return empty list on error
    }
  }

  // Instance method (if needed elsewhere)
  List<Offset> convertJsonToOffsets(String jsonString) {
    return Measure.convertJsonToOffsetsStatic(jsonString);
  }

  // Helper method to get headers with JWT token
  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    const storage = FlutterSecureStorage(); // Create storage instance
    final token = await storage.read(key: 'jwt');
    final headers = <String, String>{};

    // Set Content-Type for JSON requests unless it's multipart
    // For MultipartRequest, the http package handles the Content-Type header itself
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json; charset=UTF-8';
    }
    // Add Authorization header if token exists
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Modified method to accept veterinarianId as a parameter
  Future<bool> firstUploadToServer({required int currentVeterinarianId}) async {
    try {
      // Get headers (includes JWT)
      final headers = await _getHeaders(isMultipart: true);

      var request = http.MultipartRequest(
        'POST',
        // Ensure endpoint is correct (measure vs measures)
        Uri.parse('http://10.0.2.2:9090/measure'),
      );
      request.headers.addAll(headers); // Add headers to request

      // Add fields to the request
      request.fields['date'] = DateTime.now().toIso8601String();
      request.fields['coordinates'] = convertOffsetsToJson(coordinates);
      request.fields['horseId'] = horseId.toString();
      // Use the ID passed as a parameter
      request.fields['veterinarianId'] = currentVeterinarianId.toString();
      // Add appointmentId if it exists
      if (appointmentId != null) {
        request.fields['appointmentId'] = appointmentId.toString();
      }

      // Add the picture file if the path is valid
      if (picturePath.isNotEmpty) {
        final imageFile = File(picturePath);
        if (await imageFile.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
                'picture', // Ensure this field name matches backend expectation
                picturePath),
          );
        } else {
          debugPrint("Picture file not found at path: $picturePath");
          // Consider if this is an error or proceed without image
        }
      } else {
        debugPrint("No picture path provided for measure upload.");
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        var jsonResponse = jsonDecode(responseBody);
        var jsonMeasure = jsonResponse['measure'];

        // Update the measure object with data returned from the server
        id = (jsonMeasure['idMeasure'] as int?) ?? id;

        if (jsonMeasure.containsKey('picturePath')) {
          String receivedPicturePath = jsonMeasure['picturePath'] ?? '';
          if (receivedPicturePath.isNotEmpty) {
            picturePath = receivedPicturePath;
          }
        }

        algorithmBCS = (jsonMeasure['algorithmBCS'] as int?);
        algorithmBW = (jsonMeasure['algorithmBW'] as int?);
        // Store the veterinarianId used/returned by the server
        veterinarianId =
            (jsonMeasure['veterinarianId'] as int?) ?? currentVeterinarianId;

        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access uploading measure.');
      } else {
        throw Exception(
            'Measure upload failed. Status code: ${response.statusCode}. Response body: $responseBody');
      }
    } catch (e) {
      debugPrint("Error in firstUploadToServer: $e");
      throw Exception("Error uploading measure: ${e.toString()}");
    }
  }

  // --- editBWandBCS and deleteMeasure methods ---
  // These remain unchanged for now, but consider if they also need the vet ID
  // for backend validation/authorization.

  Future<bool> editBWandBCS(int? bw, int? bcs) async {
    try {
      final headers =
          await _getHeaders(isMultipart: true); // Assuming multipart needed

      if (id == 0) {
        throw Exception("Cannot edit measure with ID 0. Upload it first.");
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('http://10.0.2.2:9090/measure/$id'),
      );
      request.headers.addAll(headers);

      if (bw != null) {
        request.fields['userBW'] = bw.toString();
      }
      if (bcs != null) {
        request.fields['userBCS'] = bcs.toString();
      }

      if (request.fields.isEmpty) {
        debugPrint("No BW or BCS values provided to edit.");
        return true;
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);
        userBW = (jsonResponse['userBW'] as int?) ?? userBW;
        userBCS = (jsonResponse['userBCS'] as int?) ?? userBCS;
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access editing measure.');
      } else {
        throw Exception(
            'Edit BW and BCS failed. Status code: ${response.statusCode}. Response body: $responseBody');
      }
    } catch (e) {
      debugPrint("Error in editBWandBCS: $e");
      throw Exception("Error editing BW and BCS: ${e.toString()}");
    }
  }

  Future<bool> deleteMeasure() async {
    try {
      final headers = await _getHeaders(); // Assuming non-multipart for DELETE

      if (id == 0) {
        return true;
      }

      // Standard http.delete is often preferred for DELETE requests
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:9090/measure/$id'),
        headers: headers,
      );

      // Check for 200 OK or 204 No Content for successful deletion
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access deleting measure.');
      } else {
        throw Exception(
            'Delete measure failed. Status code: ${response.statusCode}. Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint("Error in deleteMeasure: $e");
      throw Exception("Error deleting measure: ${e.toString()}");
    }
  }
}
