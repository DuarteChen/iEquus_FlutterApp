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
    List<Offset> parsedCoordinates = [];
    if (json['coordinates'] is String) {
      try {
        parsedCoordinates =
            Measure.convertJsonToOffsetsStatic(json['coordinates']);
      } catch (e) {
        debugPrint("Error parsing coordinates from JSON: $e");
      }
    } else if (json['coordinates'] is List) {
      try {
        parsedCoordinates = (json['coordinates'] as List).map((point) {
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
      id: json['idMeasure'] ?? 0,
      userBW: json['userBW'],
      algorithmBW: json['algorithmBW'],
      userBCS: json['userBCS'],
      algorithmBCS: json['algorithmBCS'],
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      coordinates: parsedCoordinates,
      picturePath: json['picturePath'] ?? '',
      favorite: json['favorite'],
      horseId: json['horseId'] ?? 0,
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

  static List<Offset> convertJsonToOffsetsStatic(String jsonString) {
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((point) {
        if (point is Map && point.containsKey('x') && point.containsKey('y')) {
          final double? x = (point['x'] as num?)?.toDouble();
          final double? y = (point['y'] as num?)?.toDouble();
          if (x != null && y != null) {
            return Offset(x, y);
          }
        }

        debugPrint("Invalid point format in JSON coordinates: $point");
        return Offset.zero;
      }).toList();
    } catch (e) {
      debugPrint("Error decoding JSON coordinates string: $e");
      return [];
    }
  }

  // Instance method (if needed elsewhere)
  List<Offset> convertJsonToOffsets(String jsonString) {
    return Measure.convertJsonToOffsetsStatic(jsonString);
  }

  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    const storage = FlutterSecureStorage(); // Create storage instance
    final token = await storage.read(key: 'jwt');
    final headers = <String, String>{};

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json; charset=UTF-8';
    }

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<bool> firstUploadToServer({required int currentVeterinarianId}) async {
    try {
      final headers = await _getHeaders(isMultipart: true);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://iequus.craveirochen.pt/measure'),
      );
      request.headers.addAll(headers);

      request.fields['date'] = DateTime.now().toIso8601String();
      request.fields['coordinates'] = convertOffsetsToJson(coordinates);
      request.fields['horseId'] = horseId.toString();

      request.fields['veterinarianId'] = currentVeterinarianId.toString();

      if (appointmentId != null) {
        request.fields['appointmentId'] = appointmentId.toString();
      }

      if (picturePath.isNotEmpty) {
        final imageFile = File(picturePath);
        if (await imageFile.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath('picture', picturePath),
          );
        } else {
          debugPrint("Picture file not found at path: $picturePath");
        }
      } else {
        debugPrint("No picture path provided for measure upload.");
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        var jsonResponse = jsonDecode(responseBody);
        var jsonMeasure = jsonResponse['measure'];

        id = (jsonMeasure['idMeasure'] as int?) ?? id;

        if (jsonMeasure.containsKey('picturePath')) {
          String receivedPicturePath = jsonMeasure['picturePath'] ?? '';
          if (receivedPicturePath.isNotEmpty) {
            picturePath = receivedPicturePath;
          }
        }

        algorithmBCS = (jsonMeasure['algorithmBCS'] as int?);
        algorithmBW = (jsonMeasure['algorithmBW'] as int?);

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

  Future<bool> editBWandBCS(int? bw, int? bcs) async {
    try {
      final headers = await _getHeaders(isMultipart: true);

      if (id == 0) {
        throw Exception("Cannot edit measure with ID 0. Upload it first.");
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('https://iequus.craveirochen.pt/measure/$id'),
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
      final headers = await _getHeaders();

      if (id == 0) {
        return true;
      }

      final response = await http.delete(
        Uri.parse('https://iequus.craveirochen.pt/measure/$id'),
        headers: headers,
      );

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
