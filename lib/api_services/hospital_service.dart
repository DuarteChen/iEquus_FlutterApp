import 'dart:convert';
import 'dart:developer' as developer;

import 'package:equus/config/api_constants.dart';
import 'package:equus/models/hospital.dart';
import 'package:http/http.dart' as http;

class HospitalService {
  HospitalService();

  Future<List<Hospital>> fetchHospitals() async {
    final url = Uri.parse('$apiBaseUrl/hospitals');
    try {
      // Assuming /hospitals endpoint doesn't require authentication
      // If it does, use: final headers = await HttpClient().getHeaders();
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> hospitalData = jsonDecode(response.body);
        return hospitalData.map((data) => Hospital.fromMap(data)).toList();
      } else {
        developer.log(
            'Failed to load hospitals: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load hospitals');
      }
    } catch (e) {
      developer.log('Error fetching hospitals: $e');
      throw Exception('Error fetching hospitals: ${e.toString()}');
    }
  }
}
