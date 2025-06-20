import 'dart:convert';
import 'package:equus/config/api_constants.dart';
import 'package:equus/models/veterinarian.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class VeterinarianService {
  // Default constructor, can be omitted if no specific initialization is needed.
  VeterinarianService();

  /// Fetches the data for the currently authenticated veterinarian.
  /// Relies on the JWT token stored in secure storage.
  Future<Veterinarian?> fetchCurrentVeterinarian() async {
    final url = Uri.parse('$apiBaseUrl/veterinarian');
    try {
      // Use the centralized HttpClient().getHeaders() to include the auth token.
      final headers = await HttpClient().getHeaders();

      // Use http.get directly, similar to MeasureService's approach.
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Veterinarian.fromMap(data);
      } else {
        developer.log(
            'Failed to load veterinarian: ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e) {
      developer.log('Error fetching veterinarian: $e');
      return null;
    }
  }

  Future<void> registerVeterinarian({
    required String name,
    required String email,
    required String password,
    String? idCedulaProfissional,
    String? phoneNumber,
    String? phoneCountryCode, // Expecting abbreviation e.g., "PT"
    int? hospitalId,
  }) async {
    final url = Uri.parse('$apiBaseUrl/register');
    try {
      var request = http.MultipartRequest('POST', url);

      // Add fields to the multipart request
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;

      if (idCedulaProfissional != null && idCedulaProfissional.isNotEmpty) {
        request.fields['idCedulaProfissional'] = idCedulaProfissional;
      }
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        request.fields['phoneNumber'] = phoneNumber;
        if (phoneCountryCode != null && phoneCountryCode.isNotEmpty) {
          // Backend expects the country *abbreviation* for phoneCountryCode
          request.fields['phoneCountryCode'] = phoneCountryCode;
        }
      }
      if (hospitalId != null) {
        request.fields['hospitalId'] = hospitalId.toString();
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201 && response.statusCode != 200) {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['msg'] ??
            'Registration failed. Status: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error in VeterinarianService.registerVeterinarian: $e');
      throw Exception("Error during registration");
    }
  }
}
