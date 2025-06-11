import 'dart:convert';
import 'dart:io';
import 'package:equus/config/api_constants.dart';
import 'package:equus/models/xray_label.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class XRayService {
  Future<Map<String, dynamic>> uploadXRay(int horseId, File imageFile) async {
    final headers = await HttpClient().getHeaders(isMultipart: true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiBaseUrl/xray'),
      );
      request.headers.addAll(headers);
      request.fields['horseId'] = horseId.toString();
      request.files.add(
        await http.MultipartFile.fromPath(
          'picture', // This 'picture' key must match your backend API
          imageFile.path,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var responseBody = response.body;

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = jsonDecode(responseBody);
        final String? returnedUrl = jsonResponse['returnedImageUrl'];
        final Map<String, dynamic>? coordinatesData =
            jsonResponse['coordinates_data'] as Map<String, dynamic>?;

        if (returnedUrl == null) {
          throw Exception('API did not return an image URL.');
        }

        List<XRayLabel> parsedLabels = [];
        if (coordinatesData != null) {
          for (var value in coordinatesData.values) {
            if (value is Map<String, dynamic>) {
              // Use the updated XRayLabel.fromJson
              parsedLabels.add(XRayLabel.fromJson(value));
            }
          }
        }
        return {
          'uploadedImageUrl': returnedUrl,
          'xrayLabels': parsedLabels,
        };
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access uploading X-Ray.');
      } else {
        throw Exception(
            'Upload failed. Status: ${response.statusCode}. Body: $responseBody');
      }
    } catch (e) {
      developer.log("Error in XRayService.uploadXRay: $e");
      throw Exception("Error uploading X-Ray: ${e.toString()}");
    }
  }
}
