import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:equus/api_services/measure_service.dart'; // Import MeasureService
import 'dart:developer' as developer; // For logging

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

  Future<bool> firstUploadToServer({required int currentVeterinarianId}) async {
    final measureService = MeasureService();
    try {
      final updatedData =
          await measureService.uploadMeasure(this, currentVeterinarianId);

      id = updatedData['id'] ?? id;
      picturePath = updatedData['picturePath'] ?? picturePath;
      algorithmBCS = updatedData['algorithmBCS'];
      algorithmBW = updatedData['algorithmBW'];
      veterinarianId = updatedData['veterinarianId'] ?? veterinarianId;
      return true;
    } catch (e) {
      developer.log("Error in Measure.firstUploadToServer: $e");
      throw Exception("Error uploading measure: ${e.toString()}");
    }
  }

  Future<bool> editBWandBCS(int? bw, int? bcs) async {
    final measureService = MeasureService();
    try {
      if (id == 0) {
        throw Exception("Cannot edit measure with ID 0. Upload it first.");
      }

      // Check if there's anything to update
      if (bw == null && bcs == null) {
        debugPrint("No BW or BCS values provided to edit.");
        return true;
      }

      final updatedData =
          await measureService.updateMeasureBWandBCS(id, bw, bcs);

      if (updatedData.containsKey('userBW')) {
        userBW = updatedData['userBW'];
      }
      if (updatedData.containsKey('userBCS')) {
        userBCS = updatedData['userBCS'];
      }
      return true;
    } catch (e) {
      developer.log("Error in Measure.editBWandBCS: $e");
      throw Exception("Error editing BW and BCS: ${e.toString()}");
    }
  }

  Future<void> deleteMeasure() async {
    final measureService = MeasureService();
    try {
      if (id == 0) {
        // Optionally log or handle this case - measure not on server
        return;
      }
      await measureService.deleteMeasureById(id);
    } catch (e) {
      developer.log("Error in Measure.deleteMeasure: $e");
      throw Exception("Error deleting measure: ${e.toString()}");
    }
  }
}
