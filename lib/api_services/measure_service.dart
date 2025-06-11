import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:equus/config/api_constants.dart';
import 'package:equus/models/measure.dart'; // Import Measure model
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint

class MeasureService {
  Future<Map<String, dynamic>> uploadMeasure(
      Measure measure, int currentVeterinarianId) async {
    try {
      final headers = await HttpClient().getHeaders(isMultipart: true);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiBaseUrl/measure'),
      );
      request.headers.addAll(headers);

      request.fields['date'] = DateTime.now().toIso8601String();
      request.fields['coordinates'] =
          measure.convertOffsetsToJson(measure.coordinates);
      request.fields['horseId'] = measure.horseId.toString();

      request.fields['veterinarianId'] = currentVeterinarianId.toString();

      if (measure.appointmentId != null) {
        request.fields['appointmentId'] = measure.appointmentId.toString();
      }

      if (measure.picturePath.isNotEmpty) {
        final imageFile = File(measure.picturePath);
        if (await imageFile.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath('picture', measure.picturePath),
          );
        } else {
          debugPrint("Picture file not found at path: ${measure.picturePath}");
        }
      } else {
        debugPrint("No picture path provided for measure upload.");
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        var jsonResponse = jsonDecode(responseBody);
        var jsonMeasure = jsonResponse['measure'];

        // Prepare data to return for updating the model instance
        Map<String, dynamic> updatedData = {
          'id': jsonMeasure['idMeasure'] as int?,
          'picturePath': measure.picturePath, // Default to original
          'algorithmBCS': jsonMeasure['algorithmBCS'] as int?,
          'algorithmBW': jsonMeasure['algorithmBW'] as int?,
          'veterinarianId':
              (jsonMeasure['veterinarianId'] as int?) ?? currentVeterinarianId,
        };

        if (jsonMeasure.containsKey('picturePath')) {
          String receivedPicturePath = jsonMeasure['picturePath'] ?? '';
          if (receivedPicturePath.isNotEmpty) {
            updatedData['picturePath'] = receivedPicturePath;
          }
        }
        return updatedData;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access uploading measure.');
      } else {
        throw Exception(
            'Measure upload failed. Status code: ${response.statusCode}. Response body: $responseBody');
      }
    } catch (e) {
      developer.log("Error in MeasureService.uploadMeasure: $e");
      throw Exception("Error uploading measure: ${e.toString()}");
    }
  }

  Future<Map<String, dynamic>> updateMeasureBWandBCS(
      int measureId, int? bw, int? bcs) async {
    try {
      final headers = await HttpClient().getHeaders(
          isMultipart:
              true); // Multipart if backend expects it, otherwise false

      if (measureId == 0) {
        throw Exception("Cannot edit measure with ID 0. Upload it first.");
      }

      var request = http.MultipartRequest(
        // Using MultipartRequest if your backend expects form-data for PUT
        'PUT',
        Uri.parse('$apiBaseUrl/measure/$measureId'),
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
        return {}; // Or throw an error, or return current values
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);
        return {
          'userBW': jsonResponse['userBW'] as int?,
          'userBCS': jsonResponse['userBCS'] as int?,
        };
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access editing measure.');
      } else {
        throw Exception(
            'Edit BW and BCS failed. Status code: ${response.statusCode}. Response body: $responseBody');
      }
    } catch (e) {
      developer.log("Error in MeasureService.updateMeasureBWandBCS: $e");
      throw Exception("Error editing BW and BCS: ${e.toString()}");
    }
  }

  Future<void> deleteMeasureById(int measureId) async {
    try {
      final headers = await HttpClient().getHeaders();

      final response = await http.delete(
        Uri.parse('$apiBaseUrl/measure/$measureId'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return; // Success
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access deleting measure.');
      } else {
        throw Exception(
            'Delete measure failed. Status code: ${response.statusCode}. Response body: ${response.body}');
      }
    } catch (e) {
      developer.log("Error in MeasureService.deleteMeasureById: $e");
      throw Exception("Error deleting measure: ${e.toString()}");
    }
  }
}
